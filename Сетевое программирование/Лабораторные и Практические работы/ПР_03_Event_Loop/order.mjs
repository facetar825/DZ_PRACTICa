console.log('1. Синхронный код');
setTimeout(() => console.log('4. Таймер'), 0);
Promise.resolve().then(() => console.log('3. Promise'));
console.log('2. Синхронный код');
