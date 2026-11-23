import { pathToFileURL } from 'node:url';
import { setTimeout as delay } from 'node:timers/promises';

const BASE_URL = 'http://127.0.0.1:3041';

export async function request(path, { method = 'GET', body, timeout = 1500, headers = {} } = {}) {
    const started = performance.now();
    const requestHeaders = new Headers(headers);
    if (body !== undefined && !requestHeaders.has('Content-Type')) {
        requestHeaders.set('Content-Type', 'application/json');
    }
    try {
        const response = await fetch(BASE_URL + path, {
            method, headers: requestHeaders,
            body: body === undefined ? undefined : JSON.stringify(body),
            signal: AbortSignal.timeout(timeout),
        });
        const raw = await response.text();
        let data = raw;
        try { data = JSON.parse(raw); } catch { /* Сохраняем обычный текст. */ }
        const elapsed = Math.round(performance.now() - started);
        console.log(method, path, {
            status: response.status, ok: response.ok,
            contentType: response.headers.get('content-type'),
            cacheControl: response.headers.get('cache-control'),
            elapsed, data,
        });
        return { status: response.status, ok: response.ok, data, elapsed };
    } catch (error) {
        console.error(method, path, 'Нет полного HTTP-ответа.', error.name,
            error.cause?.code ?? error.message,
            Math.round(performance.now() - started) + ' ms');
        if (error.cause?.code === 'ECONNREFUSED') {
            console.error('Запустите сервер из netlab-07: node server.mjs');
        }
        return null;
    }
}

export async function getStatus() {
    let response = await request('/api/status');
    if (response === null) {
        await delay(250);
        response = await request('/api/status');
    }
    return response?.ok ? response.data : null;
}
export async function getEvents() {
    const response = await request('/api/events');
    return response?.ok ? response.data.events : null;
}
export async function createEvent(station, message) {
    const response = await request('/api/events', { method: 'POST', body: { station, message } });
    return response?.ok ? response.data : null;
}

async function main() {
    const [command = 'demo', ...args] = process.argv.slice(2);
    if (command === 'status') return getStatus();
    if (command === 'events') return getEvents();
    if (command === 'send' && args.length >= 2) return createEvent(args[0], args.slice(1).join(' '));
    if (command === 'slow') {
        const timeout = Number(args[0] ?? 1000);
        if (!Number.isInteger(timeout) || timeout < 1 || timeout > 60000) {
            console.error('Тайм-аут должен быть целым числом от 1 до 60000 мс.');
            return null;
        }
        return request('/api/slow?ms=3000', { timeout });
    }
    if (command !== 'demo') {
        console.error('Команды: status, events, send PC-07 "текст", slow 1000, demo');
        return null;
    }
    await getStatus();
    await getEvents();
    await createEvent('PC-07', 'REQUEST_HELP');
    await getEvents();
    await request('/missing');
    await request('/api/error');
    await request('/api/events', { method: 'POST', body: { station: 'PC-07', message: '' } });
    await request('/api/events', { method: 'PUT' });
    await request('/api/slow?ms=3000', { timeout: 1000 });
    await request('/api/slow?ms=3000', { timeout: 4000 });
    return true;
}
if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
    const result = await main();
    if (result === null) process.exitCode = 1;
}
