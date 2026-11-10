import net from 'node:net';
import { createInterface } from 'node:readline';

const HOST = '127.0.0.1';
const PORT = 3020;
const socket = net.createConnection({ host: HOST, port: PORT });
const terminal = createInterface({
  input: process.stdin,
  output: process.stdout,
  prompt: 'NetLab> ',
});

socket.setEncoding('utf8');
let pending = '';
let connected = false;

socket.on('connect', () => {
  connected = true;
  console.log('Подключено к NetLab');
  terminal.prompt();
});

socket.on('data', (chunk) => {
  pending += chunk;
  let index;
  while ((index = pending.indexOf('\n')) !== -1) {
    const response = pending.slice(0, index).replace(/\r$/, '');
    pending = pending.slice(index + 1);
    console.log('\n' + response);
    if (response === 'BYE' || response === 'ERROR SERVER_FULL' ||
        response === 'ERROR IDLE_TIMEOUT' || response === 'ERROR LINE_TOO_LONG') {
      terminal.close();
    }
  }
  if (connected && !terminal.closed && !socket.destroyed) terminal.prompt();
});

terminal.on('line', (line) => {
  if (!socket.destroyed && !socket.writableEnded) socket.write(line.trim() + '\n');
  if (!terminal.closed) terminal.prompt();
});

socket.on('error', (error) => {
  console.error('Ошибка соединения:', error.code || '-', error.message);
  terminal.close();
});

socket.on('close', () => {
  console.log('TCP-соединение закрыто');
  terminal.close();
});

terminal.on('close', () => {
  if (!socket.destroyed && !socket.writableEnded) socket.end();
});
