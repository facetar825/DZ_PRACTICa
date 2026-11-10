import dgram from 'node:dgram';
import { isIP } from 'node:net';

const PORT = 3030;
const FIRST_GROUP = '239.255.10.10';
const SECOND_GROUP = '239.255.10.11';
const mode = (process.argv[2] || 'unicast').toLowerCase();
const args = process.argv.slice(3);

function usage() {
  console.log('Использование:');
  console.log('  node sender.mjs unicast [IPv4] [текст объявления]');
  console.log('  node sender.mjs broadcast <broadcast-IPv4> [текст объявления]');
  console.log('  node sender.mjs multicast [239.255.10.10|239.255.10.11] [текст объявления]');
}

let target;
let messageParts;
if (mode === 'unicast') {
  const hasAddress = args[0] && isIP(args[0]) === 4;
  target = hasAddress ? args[0] : '127.0.0.1';
  messageParts = hasAddress ? args.slice(1) : args;
} else if (mode === 'broadcast') {
  if (!args[0] || isIP(args[0]) !== 4) {
    console.error('Для Broadcast укажите IPv4 broadcast-адрес своей подсети.');
    usage();
    process.exit(1);
  }
  target = args[0];
  messageParts = args.slice(1);
} else if (mode === 'multicast') {
  const hasAddress = args[0] && isIP(args[0]) === 4;
  target = hasAddress ? args[0] : FIRST_GROUP;
  if (target !== FIRST_GROUP && target !== SECOND_GROUP) {
    console.error('Для опыта доступны две multicast-группы:', FIRST_GROUP, SECOND_GROUP);
    process.exit(1);
  }
  messageParts = hasAddress ? args.slice(1) : args;
} else {
  console.error('Неизвестный режим:', mode);
  usage();
  process.exit(1);
}

const text = messageParts.join(' ').trim() || `${mode.toUpperCase()}: NetLab announcement`;
const socket = dgram.createSocket('udp4');
let finished = false;

function finish(code = 0) {
  if (finished) return;
  finished = true;
  if (code) process.exitCode = code;
  try { socket.close(); } catch { /* закрывается после ошибки создания */ }
}

socket.on('error', (error) => {
  console.error('[SENDER ERROR]', error.message);
  finish(1);
});

socket.bind(0, '0.0.0.0', () => {
  try {
    if (mode === 'broadcast') socket.setBroadcast(true);
    if (mode === 'multicast') {
      socket.setMulticastTTL(1);
      socket.setMulticastLoopback(true);
      if (process.env.MULTICAST_IFACE) {
        socket.setMulticastInterface(process.env.MULTICAST_IFACE);
      }
    }
    socket.send(text, PORT, target, (error) => {
      if (error) {
        console.error('Отправка не удалась:', error.message);
        finish(1);
        return;
      }
      console.log('Датаграмма передана ОС:', text);
      console.log('Назначение:', `${target}:${PORT}`);
      console.log('UDP не подтверждает получение сообщения адресатом.');
      finish();
    });
  } catch (error) {
    console.error('Настройка сокета:', error.message);
    finish(1);
  }
});
