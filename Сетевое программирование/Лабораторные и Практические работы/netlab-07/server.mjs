import http from 'node:http';

const events = [];
let nextId = 1;
let requestsCount = 0;
const stations = ['PC-01', 'PC-02', 'PC-03'];

function json(res, status, data) {
    if (res.destroyed) return;
    res.writeHead(status, {
        'Content-Type': 'application/json; charset=utf-8',
        'Cache-Control': 'no-store',
    });
    res.end(JSON.stringify(data));
}

async function readJson(req) {
    const chunks = [];
    let total = 0;
    for await (const chunk of req) {
        total += chunk.length;
        if (total <= 4096) chunks.push(chunk);
    }
    if (total > 4096) throw Object.assign(new Error('BODY_TOO_LARGE'), { status: 413 });
    try {
        return JSON.parse(Buffer.concat(chunks).toString('utf8'));
    } catch {
        throw Object.assign(new Error('INVALID_JSON'), { status: 400 });
    }
}

const server = http.createServer(async (req, res) => {
    requestsCount++;
    req.on('error', (error) => console.error('[REQUEST]', error.message));
    res.on('error', (error) => console.error('[RESPONSE]', error.message));
    res.on('finish', () => console.log(req.method, req.url, res.statusCode));
    try {
        const url = new URL(req.url, 'http://localhost');
        const path = url.pathname;
        const eventMatch = /^\/api\/events\/([1-9]\d*)$/.exec(path);
        const routes = {
            '/': ['GET'], '/api/status': ['GET'], '/api/about': ['GET'],
            '/api/stations': ['GET'], '/api/events': ['GET', 'POST'],
            '/api/slow': ['GET'], '/api/error': ['GET'],
        };
        const allowed = eventMatch ? ['GET', 'DELETE'] : routes[path];
        if (!allowed) return json(res, 404, { error: 'NOT_FOUND' });
        if (!allowed.includes(req.method)) {
            res.setHeader('Allow', allowed.join(', '));
            req.resume();
            return json(res, 405, { error: 'METHOD_NOT_ALLOWED' });
        }
        if (eventMatch) {
            const index = events.findIndex((event) => String(event.id) === eventMatch[1]);
            if (index === -1) return json(res, 404, { error: 'NOT_FOUND' });
            if (req.method === 'DELETE') {
                events.splice(index, 1);
                res.writeHead(204, { 'Cache-Control': 'no-store' });
                return res.end();
            }
            return json(res, 200, events[index]);
        }
        if (path === '/') {
            res.writeHead(200, { 'Content-Type': 'text/html; charset=utf-8' });
            return res.end('<!doctype html><html lang="ru"><meta charset="utf-8"><title>NetLab HTTP</title><h1>NetLab HTTP</h1>' +
                Object.keys(routes).filter((route) => route !== '/').map((route) => '<p><a href="' + route + '">' + route + '</a></p>').join('') +
                '<p>После создания события: GET /api/events/:id, DELETE /api/events/:id.</p></html>');
        }
        if (path === '/api/status') return json(res, 200, {
            service: 'NetLab', status: 'online', eventsCount: events.length,
            requestsCount, time: new Date().toISOString(),
        });
        if (path === '/api/about') return json(res, 200, { name: 'NetLab', version: '1.0.0' });
        if (path === '/api/stations') return json(res, 200, { stations });
        if (path === '/api/error') return json(res, 503, { error: 'SERVICE_UNAVAILABLE' });
        if (path === '/api/slow') {
            const ms = Number(url.searchParams.get('ms') ?? 3000);
            const delay = Number.isFinite(ms) ? Math.max(0, Math.min(ms, 5000)) : 3000;
            const timer = setTimeout(() => json(res, 200, { delayedMs: delay }), delay);
            res.on('close', () => clearTimeout(timer));
            return;
        }
        if (req.method === 'GET') return json(res, 200, { events });
        const type = (req.headers['content-type'] ?? '').split(';')[0].trim().toLowerCase();
        if (type !== 'application/json') {
            req.resume();
            return json(res, 415, { error: 'JSON_REQUIRED' });
        }
        const body = await readJson(req);
        if (!body || typeof body !== 'object' || Array.isArray(body) ||
            typeof body.station !== 'string' || typeof body.message !== 'string' ||
            !body.station.trim() || body.station.trim().length > 40 ||
            !body.message.trim() || body.message.trim().length > 120) {
            return json(res, 400, { error: 'INVALID_EVENT' });
        }
        const event = {
            id: nextId++, station: body.station.trim(), message: body.message.trim(),
            createdAt: new Date().toISOString(),
        };
        events.push(event);
        json(res, 201, event);
    } catch (error) {
        json(res, error.status ?? 500, { error: error.status ? error.message : 'INTERNAL_ERROR' });
    }
});
server.requestTimeout = 10000;
server.on('error', (error) => {
    console.error('[SERVER]', error.code ?? error.message);
    process.exitCode = 1;
});
server.listen(3041, '127.0.0.1', () => console.log('NetLab HTTP: http://127.0.0.1:3041'));
