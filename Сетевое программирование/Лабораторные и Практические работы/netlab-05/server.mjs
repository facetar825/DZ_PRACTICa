import net from 'node:net';

// Практическая работа №5: устойчивый многоклиентский TCP-сервер NetLab.
const HOST = '127.0.0.1';
const PORT = 3020;
const MAX_CLIENTS = 5; // Самостоятельная часть: лимит увеличен с 3 до 5.
const IDLE_MS = Number(process.env.NETLAB_IDLE_MS || 20_000);
const MAX_LINE_BYTES = 1024;
const WARNING_LEAD_MS = Math.min(5000, Math.max(100, Math.floor(IDLE_MS / 4)));

if (!Number.isFinite(IDLE_MS) || IDLE_MS < 500) {
  console.error('NETLAB_IDLE_MS должно быть числом не меньше 500 мс');
  process.exit(1);
}

const clients = new Map(); // socket -> { id, pending, commands, warningTimer, closing }
let nextId = 1;

function now() {
  return new Date().toLocaleString('ru-RU');
}

function send(socket, line) {
  if (!socket.destroyed && !socket.writableEnded) socket.write(line + '\n');
}

function broadcast(line, except = null) {
  for (const socket of clients.keys()) {
    if (socket !== except) send(socket, line);
  }
}

function endConnection(socket, state, message) {
  if (state.closing) return;
  state.closing = true;
  clearTimeout(state.warningTimer);
  if (!socket.destroyed && !socket.writableEnded) socket.end(message + '\n');
}

function armWarning(socket, state) {
  clearTimeout(state.warningTimer);
  if (state.closing) return;
  state.warningTimer = setTimeout(() => {
    if (!state.closing && !socket.destroyed && !socket.writableEnded) {
      send(socket, 'WARNING IDLE');
    }
  }, Math.max(0, IDLE_MS - WARNING_LEAD_MS));
  state.warningTimer.unref();
}

function processCommand(socket, state, rawLine) {
  // Ограничение проверено по исходным байтам ДО преобразования текста.
  const line = rawLine.toString('utf8').trim();
  if (!line) return;
  state.commands++;

  if (line === 'PING') {
    send(socket, 'PONG');
  } else if (line === 'STATS') {
    send(socket, `STATS clients=${clients.size} commands=${state.commands}`);
  } else if (line.startsWith('SAY ')) {
    const message = line.slice(4).trim();
    if (!message) {
      send(socket, 'ERROR EMPTY_MESSAGE');
    } else {
      broadcast(`[${state.id}] ${message}`, socket);
      send(socket, 'SENT');
    }
  } else if (line === 'WHO') {
    const roster = [...clients.entries()]
      .map(([peer, info]) => `${info.id}:${peer.remotePort}`)
      .join(', ');
    send(socket, 'WHO ' + roster);
  } else if (line === 'HELP') {
    send(socket, 'HELP PING, SAY текст, STATS, WHO, HELP, IDLE, QUIT');
  } else if (line === 'IDLE') {
    send(socket, `IDLE ${IDLE_MS / 1000} секунд`);
  } else if (line === 'QUIT') {
    endConnection(socket, state, 'BYE');
  } else {
    send(socket, 'ERROR UNKNOWN_COMMAND');
  }
}

const server = net.createServer((socket) => {
  // Обработчик ошибки должен быть установлен даже для отклонённых сокетов.
  socket.on('error', (error) => {
    console.error('[SOCKET ERROR]', error.code || '-', error.message);
  });

  if (clients.size >= MAX_CLIENTS) {
    console.log(`[${now()}] [REJECT] SERVER_FULL ${socket.remoteAddress}:${socket.remotePort}`);
    socket.end('ERROR SERVER_FULL\n');
    return;
  }

  const state = {
    id: `user-${nextId++}`,
    pending: Buffer.alloc(0),
    commands: 0,
    warningTimer: null,
    closing: false,
  };
  clients.set(socket, state);
  socket.setTimeout(IDLE_MS);
  armWarning(socket, state);

  console.log(`[${now()}] [CONNECT] ${state.id} ${socket.remoteAddress}:${socket.remotePort} active=${clients.size}`);
  send(socket, 'WELCOME ' + state.id);
  broadcast(`[SYSTEM] ${state.id} joined`, socket);

  // TCP — поток байтов: команда заканчивается символом LF; UTF-8 может
  // приходить частями. Сначала собираем байты, затем декодируем всю строку.
  socket.on('data', (chunk) => {
    if (state.closing) return;
    armWarning(socket, state);
    let start = 0;

    while (start < chunk.length && !state.closing) {
      const end = chunk.indexOf(10, start); // 10 = '\n'
      const piece = end < 0 ? chunk.subarray(start) : chunk.subarray(start, end);
      const length = state.pending.length + piece.length;
      if (length > MAX_LINE_BYTES) {
        endConnection(socket, state, 'ERROR LINE_TOO_LONG');
        return;
      }

      state.pending = Buffer.concat([state.pending, piece], length);
      if (end < 0) break;

      const completeLine = state.pending;
      state.pending = Buffer.alloc(0);
      processCommand(socket, state, completeLine);
      start = end + 1;
    }
  });

  socket.on('timeout', () => {
    console.log(`[${now()}] [TIMEOUT] ${state.id}`);
    endConnection(socket, state, 'ERROR IDLE_TIMEOUT');
  });

  socket.on('close', () => {
    clearTimeout(state.warningTimer);
    if (!clients.delete(socket)) return;
    console.log(`[${now()}] [CLOSE] ${state.id} active=${clients.size}`);
    broadcast(`[SYSTEM] ${state.id} left`);
  });
});

server.on('error', (error) => {
  console.error('[SERVER ERROR]', error.code || '-', error.message);
  process.exitCode = 1;
});

server.listen(PORT, HOST, () => {
  console.log(`NetLab 05: ${HOST}:${PORT}`);
  console.log(`MAX_CLIENTS=${MAX_CLIENTS}, IDLE_MS=${IDLE_MS}, MAX_LINE_BYTES=${MAX_LINE_BYTES}`);
});
