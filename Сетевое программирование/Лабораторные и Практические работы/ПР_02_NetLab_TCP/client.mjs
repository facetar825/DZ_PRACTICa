import net from 'node:net';
import readline from 'node:readline';
import { readLines } from '../Общие модули/lines.mjs';

const socket = net.createConnection({ host: '127.0.0.1', port: 3001 });
const input = readline.createInterface({ input: process.stdin });
const commands = [];
let ready = false;

function writePending() {
    if (!ready || socket.destroyed || socket.writableEnded) return;
    for (const command of commands.splice(0)) {
        if (command === 'BYE' || command === '/quit') {
            socket.end(command + '\n');
            input.close();
            return;
        }
        socket.write(command + '\n');
    }
}

input.on('line', (command) => {
    commands.push(command.trim());
    writePending();
});
input.on('close', () => {
    if (ready && !socket.writableEnded && !socket.destroyed) socket.end();
});
socket.on('connect', () => {
    console.log('[CONNECT] PING, TIME, /say текст, /list, BYE или /quit');
    ready = true;
    writePending();
    if (input.closed && !socket.writableEnded) socket.end();
});
readLines(socket, (line) => console.log('[DATA]', line), () => socket.destroy(), 4096);
socket.on('end', () => console.log('[END] Сервер завершил отправку'));
socket.on('error', (error) => {
    console.error('[ERROR]', error.code ?? error.message);
    process.exitCode = 1;
});
socket.on('close', (hadError) => {
    console.log('[CLOSE] hadError=' + hadError);
    input.close();
});
