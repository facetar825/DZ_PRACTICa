import net from 'node:net';
import { readLines } from '../Общие модули/lines.mjs';

const host = '127.0.0.1';
const port = 3001;
const clients = new Map();
let nextId = 1;

const server = net.createServer((socket) => {
    const id = nextId++;
    clients.set(id, socket);
    console.log('[CONNECT]', id, socket.remoteAddress, socket.remotePort);

    function send(line) {
        if (!socket.write(line + '\n') && !socket.isPaused()) {
            socket.pause();
            socket.once('drain', () => socket.resume());
        }
    }

    function finish(line) {
        clients.delete(id);
        socket.end(line + '\n');
        // Если клиент не завершает свою сторону, освобождаем сокет принудительно.
        const grace = setTimeout(() => socket.destroy(), 2000);
        grace.unref();
        socket.once('close', () => clearTimeout(grace));
    }

    socket.setTimeout(10000);
    socket.on('timeout', () => {
        console.log('[TIMEOUT]', id);
        if (!socket.writableEnded) finish('TIMEOUT');
    });
    socket.on('end', () => console.log('[END]', id));
    socket.on('error', (error) => console.error('[ERROR]', id, error.code ?? error.message));
    socket.on('close', (hadError) => {
        clients.delete(id);
        console.log('[CLOSE]', id, 'hadError=' + hadError);
    });

    readLines(socket, (line) => {
        if (socket.writableEnded) return false;
        const command = line.trim();
        if (!command) return;
        console.log('[DATA]', id, command);
        if (command === 'PING') {
            send('PONG');
        } else if (command === 'TIME') {
            send(new Date().toISOString());
        } else if (command === 'BYE' || command === '/quit') {
            finish('BYE');
            return false;
        } else if (command === '/list') {
            send('CLIENTS ' + [...clients.keys()].join(', '));
        } else if (command.startsWith('/say ')) {
            const message = command.slice(5).trim();
            for (const peer of clients.values()) {
                // Если получатель отстаёт, ограничиваем очередь его чата.
                if (!peer.writableEnded && peer.writableLength < 64 * 1024) {
                    peer.write('CHAT ' + id + ': ' + message + '\n');
                }
            }
        } else {
            send('ERROR неизвестная команда');
        }
    }, () => { if (!socket.writableEnded) finish('ERROR слишком длинная строка'); });
});

server.on('error', (error) => {
    console.error('[SERVER ERROR]', error.code ?? error.message);
    process.exitCode = 1;
});
server.listen(port, host, () => console.log('[LISTEN]', host + ':' + port));
