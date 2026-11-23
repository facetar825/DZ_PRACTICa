import assert from 'node:assert/strict';
import { spawn } from 'node:child_process';
import { once } from 'node:events';
import { setTimeout as delay } from 'node:timers/promises';
import { WebSocket } from 'ws';

const child = spawn(process.execPath, ['server.mjs'], { cwd: new URL('..', import.meta.url), stdio: ['ignore', 'pipe', 'pipe'] });
let output = '';
child.stdout.on('data', (data) => output += data);
child.stderr.on('data', (data) => output += data);
const closed = once(child, 'close');
const clients = [];
function open(options = {}) {
    const client = new WebSocket('ws://127.0.0.1:3061/ws', {
        origin: 'http://127.0.0.1:3061', ...options,
    });
    clients.push(client);
    return client;
}
try {
    for (let i = 0; !output.includes('http://127.0.0.1:3061'); i++) {
        assert.ok(i < 100, output);
        await delay(30);
    }
    const response = await fetch('http://127.0.0.1:3061');
    assert.equal(response.status, 200);
    assert.match(await response.text(), /textContent/);
    const a = open();
    const upgraded = once(a, 'upgrade');
    await once(a, 'open');
    assert.equal((await upgraded)[0].statusCode, 101);
    for (const text of ['PING', 'Привет, NetLab!', '<b>Это текст</b>']) {
        const reply = once(a, 'message');
        a.send(text);
        assert.equal((await reply)[0].toString(), 'ECHO: ' + text);
    }
    const b = open();
    await once(b, 'open');
    let reply = once(b, 'message');
    b.send(Buffer.from([1, 2, 3]));
    assert.equal((await reply)[0].toString(), 'ERROR: только текст');
    const aClosed = once(a, 'close');
    a.close(1000, 'Готово');
    assert.equal((await aClosed)[0], 1000);
    reply = once(b, 'message');
    b.send('После отключения другого клиента');
    assert.match((await reply)[0].toString(), /^ECHO:/);
    const big = open();
    await once(big, 'open');
    const bigClosed = once(big, 'close');
    big.send('Я'.repeat(1025));
    assert.equal((await bigClosed)[0], 1009);
    const bad = open({ origin: 'http://example.invalid' });
    bad.on('error', () => {});
    const rejected = await new Promise((resolve) => {
        bad.on('unexpected-response', (_, res) => { res.resume(); resolve(res.statusCode); bad.terminate(); });
    });
    assert.equal(rejected, 403);
    console.log('PASS: HTTP page, 101 upgrade, three echoes, binary rejection, close 1000, two clients, 2048-byte limit, Origin');
} finally {
    for (const client of clients) client.terminate();
    child.kill();
    await closed;
}
