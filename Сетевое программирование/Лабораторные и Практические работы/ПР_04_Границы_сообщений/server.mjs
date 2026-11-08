import net from 'node:net';
import { readLines } from '../Общие модули/lines.mjs';

const host = '127.0.0.1';
const port = 3002;
const server = net.createServer((socket) => {
    socket.setTimeout(10000, () => socket.destroy());
    socket.on('error', (error) => console.error('[ERROR]', error.code ?? error.message));

    readLines(socket, (line) => {
        if (socket.writableEnded) return false;
        if (!line.trim()) return;
        console.log('[COMMAND]', line);
        if (!socket.write('ACK: ' + line + '\n') && !socket.isPaused()) {
            socket.pause();
            socket.once('drain', () => socket.resume());
        }
    }, () => { if (!socket.writableEnded) socket.end('ERROR: превышен лимит 2048 байт\n'); });
});

server.on('error', (error) => {
    console.error('[SERVER ERROR]', error.code ?? error.message);
    process.exitCode = 1;
});
server.listen(port, host, () => console.log('[LISTEN]', host + ':' + port));
