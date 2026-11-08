const start = performance.now();
setTimeout(() => {
    console.log('Таймер на 100 мс сработал через', Math.round(performance.now() - start), 'мс');
}, 100);

while (performance.now() - start < 2000) {
    // Ограниченная демонстрация занятого главного потока.
}

console.log('Синхронная работа завершена');
