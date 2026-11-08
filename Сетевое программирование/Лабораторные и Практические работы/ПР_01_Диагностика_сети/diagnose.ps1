# Запуск из PowerShell. Вывод ipconfig предназначен для локального просмотра.
ipconfig
ping -n 2 127.0.0.1
nslookup nodejs.org
netstat -ano | Select-String '127\.0\.0\.1:3001\s+'
