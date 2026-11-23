import http from 'node:http';
import { readFileSync } from 'node:fs';
import { WebSocketServer } from 'ws';

const html = readFileSync(new URL('./index.html', import.meta.url));
const origin = 'http://127.0.0.1:3061';
const server = http.createServer((req, res) => {
    if (req.url !== '/' || req.method !== 'GET') {
        res.writeHead(404);
        res.end('Not found');
        return;
    }
    res.writeHead(200, { 'Content-Type': 'text/html; charset=utf-8' });
    res.end(html);
});
const wss = new WebSocketServer({ noServer: true, maxPayload: 2048 });

server.on('upgrade', (req, socket, head) => {
    if (req.url !== '/ws' || req.headers.origin !== origin) {
        socket.end('HTTP/1.1 403 Forbidden\r\nConnection: close\r\n\r\n');
        return;
    }
    socket.on('error', (error) => console.error('[UPGRADE ERROR]', error.message));
    wss.handleUpgrade(req, socket, head, (client) => {
        wss.emit('connection', client, req);
    });
});
wss.on('connection', (socket) => {
    console.log('[OPEN] Новый WebSocket-клиент');
    socket.on('message', (data, isBinary) => {
        if (isBinary) {
            socket.send('ERROR: только текст');
            return;
        }
        console.log('[MESSAGE]', data.toString('utf8'));
        socket.send('ECHO: ' + data.toString('utf8'));
    });
    socket.on('close', (code, reason) => console.log('[CLOSE]', code, reason.toString()));
    socket.on('error', (error) => console.error('[SOCKET ERROR]', error.message));
});
wss.on('error', (error) => console.error('[WS ERROR]', error.message));
server.on('error', (error) => {
    console.error('[SERVER ERROR]', error.code ?? error.message);
    process.exitCode = 1;
});
server.listen(3061, '127.0.0.1', () => console.log(origin));
