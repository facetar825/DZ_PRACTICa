import assert from 'node:assert/strict';
import net from 'node:net';
import { spawn } from 'node:child_process';
import { setTimeout as delay } from 'node:timers/promises';
import { fileURLToPath } from 'node:url';
import path from 'node:path';

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const HOST = '127.0.0.1';
const PORT = 3020;
let passed = 0;
const check = (label, value = true) => {
  assert.ok(value, label);
  console.log(`PASS ${++passed}. ${label}`);
};

class LineClient {
  constructor(socket) {
    this.socket = socket;
    this.buffer = '';
    this.lines = [];
    this.waiters = [];
    socket.setEncoding('utf8');
    socket.on('data', (chunk) => {
      this.buffer += chunk;
      let i;
      while ((i = this.buffer.indexOf('\n')) !== -1) {
        const line = this.buffer.slice(0, i).replace(/\r$/, '');
        this.buffer = this.buffer.slice(i + 1);
        this.lines.push(line);
        this.notify();
      }
    });
    socket.on('error', (error) => { this.error = error; });
  }
  notify() { for (const waiter of [...this.waiters]) waiter(); }
  send(line) { this.socket.write(line + '\n'); }
  async wait(match, timeout = 3500) {
    const matcher = typeof match === 'string'
      ? (line) => line === match
      : match instanceof RegExp
        ? (line) => match.test(line)
        : match;
    const item = this.lines.findIndex(matcher);
    if (item >= 0) return this.lines.splice(item, 1)[0];
    return await new Promise((resolve, reject) => {
      const timer = setTimeout(() => {
        this.waiters = this.waiters.filter((fn) => fn !== probe);
        reject(new Error(`Ответ не получен: ${String(match)}; все строки: ${this.lines.join(' / ')}`));
      }, timeout);
      const probe = () => {
        const i = this.lines.findIndex(matcher);
        if (i >= 0) {
          clearTimeout(timer);
          this.waiters = this.waiters.filter((fn) => fn !== probe);
          resolve(this.lines.splice(i, 1)[0]);
        }
      };
      this.waiters.push(probe);
    });
  }
  async close() {
    if (this.socket.destroyed) return;
    const finish = new Promise((resolve) => this.socket.once('close', resolve));
    this.socket.destroy();
    await finish;
  }
}

function connect() {
  return new Promise((resolve, reject) => {
    const socket = net.createConnection({ host: HOST, port: PORT });
    const client = new LineClient(socket);
    socket.once('connect', () => resolve(client));
    socket.once('error', reject);
  });
}

async function startServer(env = {}) {
  const server = spawn(process.execPath, ['server.mjs'], {
    cwd: root,
    env: { ...process.env, ...env },
    stdio: ['ignore', 'pipe', 'pipe'],
  });
  server.output = '';
  for (const stream of [server.stdout, server.stderr]) {
    stream.setEncoding('utf8');
    stream.on('data', (chunk) => { server.output += chunk; });
  }
  const deadline = Date.now() + 4000;
  while (!server.output.includes('NetLab 05: 127.0.0.1:3020')) {
    if (server.exitCode !== null || Date.now() >= deadline) {
      throw new Error('Сервер не запустился: ' + server.output);
    }
    await delay(30);
  }
  return server;
}

async function stopServer(server) {
  if (!server || server.exitCode !== null) return;
  server.kill('SIGTERM');
  await Promise.race([
    new Promise((resolve) => server.once('close', resolve)),
    delay(3500).then(() => { server.kill('SIGKILL'); }),
  ]);
}

let server;
const openClients = [];
try {
  server = await startServer();
  check('TCP-сервер стартовал на 127.0.0.1:3020');

  const clients = [];
  for (let i = 0; i < 5; i++) {
    const client = await connect();
    clients.push(client);
    openClients.push(client);
    const welcome = await client.wait(/^WELCOME user-\d+$/);
    assert.equal(welcome, `WELCOME user-${i + 1}`);
  }
  check('Пять клиентов получили независимые идентификаторы');

  const [a, b, c, d, e] = clients;
  a.send('PING');
  assert.equal(await a.wait('PONG'), 'PONG');
  check('PING → PONG');

  a.send('STATS');
  assert.equal(await a.wait(/^STATS /), 'STATS clients=5 commands=2');
  b.send('STATS');
  assert.equal(await b.wait(/^STATS /), 'STATS clients=5 commands=1');
  check('STATS хранит отдельные счётчики команд');

  a.send('WHO');
  const roster = await a.wait(/^WHO /);
  check('WHO показывает user-1..user-5 и их порты',
    [1, 2, 3, 4, 5].every((id) => new RegExp(`user-${id}:\\d+`).test(roster)));

  a.send('HELP');
  check('HELP перечисляет собственные команды', (await a.wait(/^HELP /)).includes('IDLE'));
  a.send('IDLE');
  assert.equal(await a.wait(/^IDLE /), 'IDLE 20 секунд');
  check('IDLE показывает 20 секунд по умолчанию');

  a.send('SAY Привет, класс!');
  assert.equal(await a.wait('SENT'), 'SENT');
  assert.equal(await b.wait('[user-1] Привет, класс!'), '[user-1] Привет, класс!');
  check('SAY передаёт сообщение другому клиенту');

  a.send('HELLO');
  assert.equal(await a.wait('ERROR UNKNOWN_COMMAND'), 'ERROR UNKNOWN_COMMAND');
  a.send('PING');
  assert.equal(await a.wait('PONG'), 'PONG');
  check('Неизвестная команда не прерывает соединение');

  const sixth = await connect();
  assert.equal(await sixth.wait('ERROR SERVER_FULL'), 'ERROR SERVER_FULL');
  await sixth.close();
  check('Шестой клиент отклонён: ERROR SERVER_FULL (лимит 5)');

  c.send('Я'.repeat(600)); // 1200 байт UTF-8, больше лимита 1024.
  assert.equal(await c.wait('ERROR LINE_TOO_LONG'), 'ERROR LINE_TOO_LONG');
  await c.close();
  await delay(50);
  check('Слишком длинная UTF-8 команда отклоняется по числу байтов');

  const replacement = await connect();
  openClients.push(replacement);
  await replacement.wait(/^WELCOME /);
  replacement.send('PING');
  assert.equal(await replacement.wait('PONG'), 'PONG');
  check('После ошибки одного клиента сервер продолжает работу');

  b.send('QUIT');
  assert.equal(await b.wait('BYE'), 'BYE');
  await b.close();
  a.send('PING');
  assert.equal(await a.wait('PONG'), 'PONG');
  check('QUIT отключает одного клиента, остальные работают');

  for (const client of openClients) await client.close();
  await stopServer(server);
  server = undefined;

  // Сокращение тайм-аута применяется только в тестах; обычное значение — 20 с.
  server = await startServer({ NETLAB_IDLE_MS: '1400' });
  const idle = await connect();
  openClients.push(idle);
  await idle.wait(/^WELCOME /);
  assert.equal(await idle.wait('WARNING IDLE', 3000), 'WARNING IDLE');
  check('WARNING IDLE отправляется до отключения без блокировки Event Loop');
  assert.equal(await idle.wait('ERROR IDLE_TIMEOUT', 3000), 'ERROR IDLE_TIMEOUT');
  check('Неактивный клиент закрывается по тайм-ауту');
  await idle.close();

  const survivor = await connect();
  openClients.push(survivor);
  await survivor.wait(/^WELCOME /);
  survivor.send('PING');
  assert.equal(await survivor.wait('PONG'), 'PONG');
  check('Сервер остаётся рабочим после тайм-аута');

  const double = spawn(process.execPath, ['server.mjs'], {
    cwd: root, stdio: ['ignore', 'pipe', 'pipe'],
  });
  let doubleLogs = '';
  for (const stream of [double.stdout, double.stderr]) {
    stream.on('data', (chunk) => { doubleLogs += chunk.toString(); });
  }
  await Promise.race([
    new Promise((resolve) => double.once('close', resolve)),
    delay(2000).then(() => double.kill('SIGKILL')),
  ]);
  check('Второй сервер на том же порту сообщает EADDRINUSE', doubleLogs.includes('EADDRINUSE'));
  await survivor.close();
  await stopServer(server);
  server = undefined;
  await delay(100);
  let refused = false;
  try { await connect(); } catch (error) { refused = error.code === 'ECONNREFUSED'; }
  check('Без сервера возникает ECONNREFUSED', refused);

  console.log(`\nИТОГО: ${passed} проверок успешно. Node.js ${process.version}`);
} catch (error) {
  console.error(`FAIL после ${passed} проверок:`, error.stack || error.message);
  process.exitCode = 1;
} finally {
  for (const client of openClients) await client.close().catch(() => {});
  await stopServer(server);
}
