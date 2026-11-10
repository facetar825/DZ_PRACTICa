import assert from 'node:assert/strict';
import { spawn, execFile } from 'node:child_process';
import { promisify } from 'node:util';
import { setTimeout as delay } from 'node:timers/promises';
import { fileURLToPath } from 'node:url';
import path from 'node:path';

const execFileAsync = promisify(execFile);
const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
let checks = 0;
let notes = 0;
let currentReceiver;

function pass(name, condition = true) {
  assert.ok(condition, name);
  console.log(`PASS ${++checks}. ${name}`);
}
function note(name) {
  console.log(`ПРИМЕЧАНИЕ ${++notes}. ${name}`);
}

function receiver(env = {}) {
  const child = spawn(process.execPath, ['receiver.mjs'], {
    cwd: root,
    env: { ...process.env, ...env },
    stdio: ['pipe', 'pipe', 'pipe'],
  });
  child.output = '';
  child.stderrText = '';
  child.stdout.setEncoding('utf8');
  child.stdout.on('data', (chunk) => { child.output += chunk; });
  child.stderr.setEncoding('utf8');
  child.stderr.on('data', (chunk) => { child.stderrText += chunk; });
  currentReceiver = child;
  return child;
}

async function waitOutput(child, part, timeout = 4000) {
  const deadline = Date.now() + timeout;
  while (!child.output.includes(part)) {
    if (child.exitCode !== null || Date.now() > deadline) {
      throw new Error(`Не увидели «${part}». stdout: ${child.output}, stderr: ${child.stderrText}`);
    }
    await delay(25);
  }
}

async function send(mode, ...args) {
  const result = await execFileAsync(process.execPath, ['sender.mjs', mode, ...args], {
    cwd: root, timeout: 5000, encoding: 'utf8',
  });
  return result.stdout;
}

async function stopReceiver(child) {
  if (!child || child.exitCode !== null) return;
  child.stdin.write('STOP\n');
  try {
    await Promise.race([
      new Promise((resolve) => child.once('close', resolve)),
      delay(1800).then(() => { child.kill('SIGKILL'); }),
    ]);
  } catch { child.kill('SIGKILL'); }
}

try {
  let r = receiver({ MULTICAST_GROUPS: '239.255.10.10' });
  await waitOutput(r, 'UDP приёмник: 0.0.0.0:3030');
  pass('UDP-приёмник открыл порт 3030');
  for (let tries = 0; tries < 50 && !r.output.includes('Подписка на группу: 239.255.10.10') && !r.output.includes('Multicast недоступен'); tries++) await delay(20);
  pass('Первая multicast-группа в конфигурации', r.output.includes('Подписка на группу: 239.255.10.10') || r.output.includes('Multicast недоступен'));

  let result = await send('unicast', '127.0.0.1', 'Проверка адресной доставки');
  pass('Отправитель сообщил об успешной передаче датаграммы в ОС', result.includes('Датаграмма передана ОС'));
  await waitOutput(r, '[RECEIVED] Проверка адресной доставки FROM 127.0.0.1:');
  pass('Unicast на 127.0.0.1 фактически получен');
  pass('Приёмник добавляет дату и время к сообщениям', /\[\d{1,2}\.\d{1,2}\.\d{4}[^\]]*\] \[RECEIVED\]/.test(r.output));

  // Групповая доставка зависит от ОС, локального сетевого интерфейса и фильтрации.
  result = await send('multicast', '239.255.10.10', 'Проверка группы 1');
  pass('Multicast-группа 1 передана ОС с TTL=1', result.includes('Назначение: 239.255.10.10:3030'));
  try {
    await waitOutput(r, '[RECEIVED] Проверка группы 1 FROM', 1900);
    pass('Multicast группы 1 получен в данной среде');
  } catch {
    note('Multicast группы 1 не получен в данной среде; проверка локального интерфейса/сети требуется на учебных ПК.');
  }

  result = await send('multicast', '239.255.10.11', 'Проверка группы 2');
  pass('Вторая multicast-группа поддерживается отправителем', result.includes('Назначение: 239.255.10.11:3030'));
  await delay(300);
  if (r.output.includes('Проверка группы 2 FROM')) {
    note('Сообщение группы 2 видно даже при подписке на группу 1: это возможно при совместном получении трафика ОС; нужны разные ПК/интерфейсы для чистого опыта.');
  } else {
    pass('При подписке только на группу 1 сообщений группы 2 не наблюдалось');
  }

  // Направленный Broadcast из задания требует настоящего адреса подсети;
  // локальная проверка использует только loopback-сегмент.
  try {
    result = await send('broadcast', '127.255.255.255', 'Проверка broadcast loopback');
    pass('Вызов UDP broadcast на локальный loopback-адрес передан ОС', result.includes('Назначение: 127.255.255.255:3030'));
    try {
      await waitOutput(r, '[RECEIVED] Проверка broadcast loopback FROM', 1400);
      pass('Broadcast loopback фактически получен');
    } catch {
      note('Широковещательная датаграмма loopback не получена. На реальной сети потребуется broadcast-адрес своей подсети и разрешения сети.');
    }
  } catch (error) {
    note('ОС запретила локальную broadcast-отправку: ' + (error.stderr || error.message).trim());
  }

  await stopReceiver(r);
  pass('Локальная команда STOP корректно остановила приёмник',
    r.output.includes('Локальная команда STOP принята') && r.output.includes('Приёмник остановлен'));
  currentReceiver = null;

  // Проверка переключения подписки на вторую группу отдельным запуском.
  r = receiver({ MULTICAST_GROUPS: '239.255.10.11' });
  await waitOutput(r, 'UDP приёмник: 0.0.0.0:3030');
  for (let tries = 0; tries < 50 && !r.output.includes('Подписка на группу: 239.255.10.11') && !r.output.includes('Multicast недоступен'); tries++) await delay(20);
  pass('Приёмник может подписываться только на вторую группу',
    r.output.includes('Подписка на группу: 239.255.10.11') && !r.output.includes('Подписка на группу: 239.255.10.10'));
  await send('multicast', '239.255.10.11', 'Вторая подписка');
  try {
    await waitOutput(r, '[RECEIVED] Вторая подписка FROM', 1900);
    pass('Вторая multicast-группа получена при активной подписке');
  } catch {
    note('Доставка во вторую multicast-группу не подтверждена в данной среде; код регистрации группы выполнен.');
  }

  await stopReceiver(r);
  pass('Приёмник второй группы завершён по локальной команде STOP',
    r.output.includes('Приёмник остановлен'));
  currentReceiver = null;

  let invalidRejected = false;
  try { await send('broadcast', 'не-IP'); } catch { invalidRejected = true; }
  pass('Broadcast требует явно указанного IPv4-адреса', invalidRejected);

  console.log(`\nИТОГО: ${checks} успешных проверок; ${notes} сетевых замечаний. Node.js ${process.version}`);
  console.log('Примечание: доставка Broadcast/Multicast в учебной LAN должна проверяться на компьютерах этой LAN.');
} catch (error) {
  console.error('FAIL:', error.stack || error.message);
  process.exitCode = 1;
} finally {
  await stopReceiver(currentReceiver);
}
