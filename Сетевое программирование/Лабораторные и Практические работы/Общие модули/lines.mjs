// Одна строка UTF-8 на сообщение. Размер проверяем до декодирования.
export function readLines(socket, onLine, onLimit, maxBytes = 2048) {
    let pending = Buffer.alloc(0);
    let stopped = false;

    socket.on('data', (chunk) => {
        if (stopped) return;
        let start = 0;
        while (start < chunk.length) {
            const newline = chunk.indexOf(0x0a, start);
            const end = newline === -1 ? chunk.length : newline;
            const part = chunk.subarray(start, end);
            if (pending.length + part.length > maxBytes) {
                stopped = true;
                pending = Buffer.alloc(0);
                onLimit();
                return;
            }
            if (newline === -1) {
                // Не сохраняем ссылку на большой буфер ради маленького остатка.
                pending = Buffer.concat([pending, part]);
                return;
            }
            const line = Buffer.concat([pending, part]).toString('utf8').replace(/\r$/, '');
            pending = Buffer.alloc(0);
            if (onLine(line) === false) {
                stopped = true;
                return;
            }
            start = newline + 1;
        }
    });
}
