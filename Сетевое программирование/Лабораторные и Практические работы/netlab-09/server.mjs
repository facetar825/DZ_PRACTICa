import http from 'node:http';
import { readFileSync } from 'node:fs';
import { WebSocketServer, WebSocket } from 'ws';

const html = readFileSync(new URL('./index.html', import.meta.url));
const clients = new Map();
let messagesCount = 0;
const server = http.createServer((req, res) => {
    res.writeHead(req.method === 'GET' && req.url === '/' ? 200 : 404, {
        'Content-Type': 'text/html; charset=utf-8', 'Cache-Control': 'no-store',
    });
    res.end(req.method === 'GET' && req.url === '/' ? html : 'Не найдено');
});
const wss = new WebSocketServer({ server, path: '/ws', maxPayload: 2048 });
function send(ws, packet) {
    if (ws.readyState !== WebSocket.OPEN) return;
    if (ws.bufferedAmount > 65536) return ws.close(1013, 'Slow client');
    ws.send(JSON.stringify(packet));
}
function online() {
    return [...clients.values()].filter((client) => client.name !== null).map(({ name }) => name);
}
function broadcast(packet) {
    for (const [ws, state] of clients) if (state.name !== null) send(ws, packet);
}
function publishOnline() {
    broadcast({
        type: 'online', users: online(),
        participants: [...clients.values()].filter((c) => c.name !== null)
            .map(({ name, connectedAt }) => ({ name, connectedAt })),
        messagesCount,
    });
}
function error(ws, code, message) { send(ws, { type: 'error', code, message }); }
wss.on('connection', (ws) => {
    ws.on('error', (err) => console.error('[WS ERROR]', err.message));
    if (clients.size >= 20) return ws.close(1013, 'Server busy');
    const state = { name: null, connectedAt: new Date().toISOString(), recent: [] };
    clients.set(ws, state);
    send(ws, { type: 'info', text: 'Подключение установлено' });
    console.log('[CONNECT]');
    ws.on('message', (raw, isBinary) => {
        const now = Date.now();
        state.recent = state.recent.filter((time) => now - time < 10000);
        if (state.recent.length >= 5) return error(ws, 'RATE_LIMIT', 'Не более 5 команд за 10 секунд');
        state.recent.push(now);
        if (isBinary) return error(ws, 'TEXT_ONLY', 'Ожидается текстовый JSON');
        let packet;
        try { packet = JSON.parse(raw.toString('utf8')); }
        catch { return error(ws, 'INVALID_JSON', 'Неверный JSON'); }
        if (!packet || typeof packet !== 'object' || Array.isArray(packet)) {
            return error(ws, 'INVALID_PACKET', 'Ожидается объект');
        }
        if (packet.type === 'join') {
            if (state.name !== null) return error(ws, 'ALREADY_JOINED', 'Имя уже задано');
            if (typeof packet.name !== 'string' || !packet.name.trim() || packet.name.trim().length > 20) {
                return error(ws, 'INVALID_NAME', 'Имя: 1–20 символов');
            }
            const name = packet.name.trim();
            if (online().includes(name)) return error(ws, 'NAME_TAKEN', 'Имя уже занято');
            state.name = name;
            send(ws, { type: 'WELCOME', text: 'Добро пожаловать, ' + name, messagesCount });
            broadcast({ type: 'system', text: name + ' подключился' });
            publishOnline();
            console.log('[JOIN]', name);
            return;
        }
        if (state.name === null) return error(ws, 'JOIN_REQUIRED', 'Сначала отправьте join');
        if (packet.type === 'who' || (packet.type === 'chat' && packet.text === '/who')) {
            send(ws, { type: 'who', users: online() });
            return;
        }
        if (!['chat', 'private'].includes(packet.type)) return error(ws, 'UNKNOWN_TYPE', 'Неизвестная команда');
        if (typeof packet.text !== 'string' || !packet.text.trim() || packet.text.trim().length > 200) {
            return error(ws, 'INVALID_TEXT', 'Текст: 1–200 символов');
        }
        let recipient;
        if (packet.type === 'private') {
            recipient = [...clients].find(([, client]) => client.name === packet.to);
            if (!recipient) return error(ws, 'USER_NOT_FOUND', 'Получатель не найден');
        }
        const message = {
            type: packet.type, name: state.name, text: packet.text.trim(),
            time: new Date().toISOString(), to: packet.to,
        };
        messagesCount++;
        if (recipient) {
            send(recipient[0], message);
            if (recipient[0] !== ws) send(ws, message);
        } else broadcast(message);
        broadcast({ type: 'stats', messagesCount });
        console.log('[MESSAGE]', state.name);
    });
    ws.on('close', (code) => {
        clients.delete(ws);
        console.log('[CLOSE]', state.name ?? 'guest', code);
        if (state.name !== null) {
            broadcast({ type: 'system', text: state.name + ' отключился' });
            publishOnline();
        }
    });
});
wss.on('error', (error) => console.error('[WSS ERROR]', error.message));
server.on('error', (error) => {
    console.error('[HTTP ERROR]', error.message);
    process.exitCode = 1;
});
server.listen(3060, '127.0.0.1', () => console.log('NetLab Chat: http://127.0.0.1:3060'));
