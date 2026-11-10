import dgram from 'node:dgram';
import { createInterface } from 'node:readline';

// Практическая №6: универсальный UDP-приёмник, управление только локально.
const PORT = 3030;
const DEFAULT_GROUP = '239.255.10.10';
const SECOND_GROUP = '239.255.10.11';
const AVAILABLE_GROUPS = new Set([DEFAULT_GROUP, SECOND_GROUP]);
const IFACE = process.env.MULTICAST_IFACE || undefined;
const groups = (process.env.MULTICAST_GROUPS || DEFAULT_GROUP)
  .split(',').map((value) => value.trim()).filter(Boolean);

if (groups.some((group) => !AVAILABLE_GROUPS.has(group))) {
  console.error('Группа должна быть 239.255.10.10 и/или 239.255.10.11');
  process.exit(1);
}

const socket = dgram.createSocket({ type: 'udp4', reuseAddr: true });
const terminal = createInterface({ input: process.stdin, output: process.stdout });
let stopping = false;

socket.on('message', (buffer, sender) => {
  console.log(`[${new Date().toLocaleString('ru-RU')}] [RECEIVED] ` +
    `${buffer.toString('utf8')} FROM ${sender.address}:${sender.port}`);
});

socket.on('error', (error) => {
  console.error('[RECEIVER ERROR]', error.message);
  stop();
});

socket.on('close', () => {
  console.log('Приёмник остановлен');
  terminal.close();
});

function stop() {
  if (stopping) return;
  stopping = true;
  try { socket.close(); } catch { terminal.close(); }
}

terminal.on('line', (line) => {
  if (line.trim().toUpperCase() === 'STOP') {
    console.log('Локальная команда STOP принята');
    stop();
  } else if (line.trim()) {
    console.log('Для остановки введите STOP');
  }
});
terminal.on('SIGINT', stop);
// Закрытие локального stdin в скрипте не является удалённой сетевой командой.
terminal.on('close', () => { if (!stopping) stop(); });

socket.bind(PORT, '0.0.0.0', () => {
  console.log(`UDP приёмник: 0.0.0.0:${PORT}`);
  console.log('Введите STOP в этом терминале для завершения');
  for (const group of new Set(groups)) {
    try {
      socket.addMembership(group, IFACE);
      console.log('Подписка на группу: ' + group + (IFACE ? ` (интерфейс ${IFACE})` : ''));
    } catch (error) {
      console.log(`Multicast недоступен для ${group}: ${error.message}`);
      console.log('Unicast по-прежнему можно проверить');
    }
  }
});
