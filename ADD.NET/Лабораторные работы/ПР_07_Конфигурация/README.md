# Практическая работа №7 — Конфигурация подключения

Выполнил: **Мингазов Ахнаф**. Проект: **AdoNetPractice07**.

Выполнены части 1–8 и дополнительная конфигурация Development. Исходное условие сохранено в `Условие.pdf`.

## Реализация

ConfigurationBuilder в общем [PracticeSupport.cs](../Shared/PracticeSupport.cs) загружает источники в порядке:

1. Обязательный appsettings.json из AppContext.BaseDirectory.
2. Необязательный appsettings.Development.json.
3. Переменные окружения — имеют наивысший приоритет.

Строка получается через GetConnectionString("CoffeeShop"). Отсутствие или пустое значение вызывает понятное сообщение. Подключение не содержится в методах SQL: CheckConnectionAsync и ShowStatisticsAsync получают его аргументом.

Файлы JSON копируются к исполняемому файлу через CopyToOutputDirectory="PreserveNewest". В appsettings.json заданы ConnectionStrings:CoffeeShop, Application:Title и Application:ShowPrices. В Development изменён Title, поэтому при запуске отображается «Консоль кофейни — локальная разработка». ShowPrices разбирается bool.TryParse; неверное значение обрабатывается как ошибка.

Меню проверяет подключение, выводит статистику товаров/клиентов/заказов, доступный каталог, поиск LIKE @search и настройки приложения. При ShowPrices=false в каталоге остаются только названия. Меню настроек показывает только Title и ShowPrices. Все SQL-операции асинхронные, строки читаются через SqlDataReader.

## Запуск и проверки конфигурации

Из корня репозитория:

```powershell
dotnet run --project "ADD.NET/Лабораторные работы/ПР_07_Конфигурация/AdoNetPractice07.csproj"
```

По умолчанию указан `(localdb)\CodexSqlPractice`, база coffee_shop, Windows-аутентификация. Настройки можно переопределить в текущем сеансе PowerShell:

```powershell
$env:ConnectionStrings__CoffeeShop = 'Server=(localdb)\CodexSqlPractice;Database=coffee_shop;Integrated Security=True;TrustServerCertificate=True;Connect Timeout=5'
$env:Application__ShowPrices = 'false'
$env:Application__Title = 'Моя кофейня'
```

Запустите приложение и проверьте пункты 1, 3 и 5. Чтобы проверить обработку ошибки подключения, временно укажите несуществующий сервер с коротким Connect Timeout. Затем удалите временные переменные:

```powershell
Remove-Item Env:ConnectionStrings__CoffeeShop
Remove-Item Env:Application__ShowPrices
Remove-Item Env:Application__Title
```

Для проверки отсутствующего ключа переименуйте CoffeeShop в Demo в JSON, убедитесь, что переменная окружения подключения удалена, запустите приложение и восстановите ключ. При изменении исходных JSON используйте dotnet run, чтобы они скопировались в выходной каталог.

## Письменные ответы

1. **Зачем выносить строку из C#:** чтобы менять сервер и базу без изменения логики приложения и не смешивать настройки с кодом.
2. **Как находится appsettings.json:** SetBasePath(AppContext.BaseDirectory) задаёт каталог исполняемого приложения; csproj копирует JSON в этот каталог.
3. **Если CoffeeShop отсутствует:** GetConnectionString возвращает null, если значение не пришло из другого источника; программа выводит сообщение и завершает запуск.
4. **Зачем AddEnvironmentVariables:** добавляет источник настроек окружения. Двойное подчёркивание разделяет вложенные ключи, например ConnectionStrings__CoffeeShop.
5. **Почему не публиковать пароли:** они дают доступ к базе и сохраняются в истории репозитория. В учебных файлах используется Windows-аутентификация без паролей.

## Проверка

21.10.2026 проект собран без ошибок и предупреждений. Проверены подключение, статистика, поиск, влияние ShowPrices, приоритет окружения над Development и основным JSON, отсутствующий ключ, неверный ShowPrices и ошибка сервера. После проверки JSON восстановлен.
