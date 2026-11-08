import net from 'node:net';
import { readLines } from '../Общие модули/lines.mjs';

const socket = net.createConnection({ host: '127.0.0.1', port: 3002 });
const expected = ['ACK: PING', 'ACK: TIME', 'ACK: ECHO Привет'];
let received = 0;

socket.setTimeout(5000, () => socket.destroy(new Error('Ответ не пришёл за 5 секунд')));
socket.on('connect', () => {
    socket.write('PING\nTIME\n');
    const echo = Buffer.from('ECHO Привет\n', 'utf8');
    // Разрезаем внутри первого многобайтового символа.
    socket.write(echo.subarray(0, 6));
    socket.write(echo.subarray(6));
});
readLines(socket, (line) => {
    console.log(line);
    if (line !== expected[received]) {
        socket.destroy(new Error('Неожиданный ответ: ' + line));
        return false;
    }
    if (++received === expected.length) {
        socket.end();
        return false;
    }
}, () => socket.destroy(new Error('Слишком длинный ответ')), 4096);
socket.on('error', (error) => {
    console.error('[ERROR]', error.code ?? error.message);
    process.exitCode = 1;
});
socket.on('close', () => {
    if (received !== expected.length) {
        console.error('Получено ответов:', received, 'из', expected.length);
        process.exitCode = 1;
    }
});
