import assert from 'node:assert/strict';
import { spawn } from 'node:child_process';
import { once } from 'node:events';
import { setTimeout as delay } from 'node:timers/promises';
import { WebSocket } from 'ws';
import { request, getStatus, getEvents, createEvent } from '../../netlab-08/client.mjs';

const children = [];
const sockets = [];
async function start(folder, text) {
    const child = spawn(process.execPath, ['server.mjs'], {
        cwd: new URL('../../' + folder + '/', import.meta.url),
        stdio: ['ignore', 'pipe', 'pipe'],
    });
    child.output = '';
    child.done = once(child, 'close');
    for (const stream of [child.stdout, child.stderr]) stream.on('data', (chunk) => child.output += chunk);
    children.push(child);
    for (let i = 0; !child.output.includes(text); i++) {
        assert.ok(i < 100, child.output);
        await delay(30);
    }
    return child;
}
async function connect() {
    const ws = new WebSocket('ws://127.0.0.1:3060/ws');
    sockets.push(ws);
    ws.packets = [];
    ws.on('message', (data) => ws.packets.push(JSON.parse(data)));
    await once(ws, 'open');
    return ws;
}
async function packet(ws, type, predicate = () => true) {
    for (let i = 0; i < 100; i++) {
        const index = ws.packets.findIndex((p) => p.type === type && predicate(p));
        if (index !== -1) return ws.packets.splice(index, 1)[0];
        await delay(10);
    }
    throw new Error('Missing packet ' + type + JSON.stringify(ws.packets));
}
const send = (ws, data) => ws.send(JSON.stringify(data));
try {
    const http = await start('netlab-07', '3041');
    const root = 'http://127.0.0.1:3041';
    const check = async (path, status, options) => {
        const response = await fetch(root + path, options);
        assert.equal(response.status, status, path);
        return response;
    };
    assert.match(await (await check('/', 200)).text(), /api\/stations/);
    const before = await getStatus();
    assert.equal(before.service, 'NetLab');
    assert.equal((await (await check('/api/stations', 200)).json()).stations.length, 3);
    assert.equal((await (await check('/api/about', 200)).json()).name, 'NetLab');
    const event = await createEvent(' PC-07 ', ' HELP ');
    assert.equal(event.station, 'PC-07');
    assert.ok((await getEvents()).some((e) => e.id === event.id));
    await check('/api/events/' + event.id, 200);
    for (const body of ['{', 'null', '[]', '{"station":"x","message":""}']) {
        await check('/api/events', 400, { method:'POST', headers:{'Content-Type':'application/json'}, body });
    }
    await check('/api/events', 413, { method:'POST', headers:{'Content-Type':'application/json'}, body:'x'.repeat(4097) });
    await check('/api/events', 415, { method:'POST', body:'text' });
    await check('/api/events', 415, { method:'POST', headers:{'Content-Type':'application/jsonBAD'}, body:'{}' });
    const method = await check('/api/events', 405, { method:'PUT' });
    assert.equal(method.headers.get('allow'), 'GET, POST');
    await check('/missing', 404);
    await check('/api/error', 503);
    await check('/api/events/' + event.id, 204, { method:'DELETE' });
    await check('/api/events/' + event.id, 404);
    const slow = fetch(root + '/api/slow?ms=500');
    const started = performance.now();
    await check('/api/status', 200);
    assert.ok(performance.now() - started < 450);
    await slow;
    assert.ok((await getStatus()).requestsCount > before.requestsCount);
    assert.equal((await request('/missing')).ok, false);
    assert.equal((await request('/api/error')).status, 503);
    assert.equal(await request('/api/slow?ms=3000', {timeout:1000}), null);
    assert.equal((await request('/api/slow?ms=3000', {timeout:4000})).status, 200);
    http.kill();
    await http.done;
    assert.equal(await getStatus(), null);
    console.log('PASS HTTP server/client: routes, validation, 413, delete, counters, concurrent delay, 404/503, timeout 1000/4000, refused connection with retry');

    await start('netlab-09', '3060');
    const page = await fetch('http://127.0.0.1:3060');
    assert.match(await page.text(), /textContent/);
    const a = await connect(), b = await connect(), c = await connect();
    for (const [ws, name] of [[a,'A'], [b,'B'], [c,'C']]) {
        send(ws, {type:'join', name});
        assert.match((await packet(ws,'WELCOME')).text, new RegExp(name));
    }
    await packet(a,'online', (p) => p.users.length === 3);
    send(a, {type:'chat', text:'<img src=x onerror=alert(1)>'});
    for (const ws of [a,b,c]) assert.match((await packet(ws,'chat')).text, /<img/);
    send(a, {type:'chat', text:'/who'});
    assert.equal((await packet(a,'who')).users.length, 3);
    send(a, {type:'private', to:'B', text:'secret'});
    assert.equal((await packet(b,'private')).text, 'secret');
    await delay(30);
    assert.ok(!c.packets.some((p) => p.type === 'private'));
    const bClosed = once(b,'close');
    b.close(1000);
    assert.equal((await bClosed)[0], 1000);
    await packet(a,'online', (p) => p.users.length === 2);
    send(c, {type:'chat', text:'still here'});
    assert.equal((await packet(a,'chat')).text, 'still here');
    const bad = await connect();
    send(bad, {type:'join', name:'A'});
    assert.equal((await packet(bad,'error')).code, 'NAME_TAKEN');
    bad.send('not-json');
    assert.equal((await packet(bad,'error')).code, 'INVALID_JSON');
    send(bad, {type:'join', name:'D'});
    await packet(bad,'WELCOME');
    send(bad, {type:'delete-all'});
    assert.equal((await packet(bad,'error')).code, 'UNKNOWN_TYPE');
    send(bad, {type:'chat', text:''});
    assert.equal((await packet(bad,'error')).code, 'INVALID_TEXT');
    send(bad, {type:'chat', text:'blocked'});
    assert.equal((await packet(bad,'error')).code, 'RATE_LIMIT');
    const huge = await connect();
    const hugeClosed = once(huge,'close');
    huge.send('x'.repeat(2049));
    assert.equal((await hugeClosed)[0], 1009);
    console.log('PASS chat: three clients, welcome, participants, broadcast, /who, private, close, duplicate, JSON, unknown type, empty text, rate and payload limits');
} finally {
    for (const ws of sockets) ws.terminate();
    for (const child of children) {
        if (child.exitCode === null) child.kill();
        await child.done;
    }
}
