import http from 'node:http';

const server = http.createServer((req, res) => {
    console.log(req.method, req.url);
    res.writeHead(200, { 'Content-Type': 'text/plain; charset=utf-8' });
    res.end('Привет от NetLab!');
});
server.on('error', (error) => {
    console.error('[SERVER ERROR]', error.code ?? error.message);
    process.exitCode = 1;
});
server.listen(3040, '127.0.0.1', () => console.log('http://127.0.0.1:3040'));
