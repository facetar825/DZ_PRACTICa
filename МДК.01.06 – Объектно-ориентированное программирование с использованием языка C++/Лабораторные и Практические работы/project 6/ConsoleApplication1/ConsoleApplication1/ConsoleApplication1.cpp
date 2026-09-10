
#include <iostream>
#include <fstream>
#include <string>
#include <vector>

using namespace std;

// ==========================================
// Базовый класс LogEntry
// ==========================================

class LogEntry
{
protected:
    string message;

public:
    LogEntry(const string& msg)
        : message(msg)
    {
    }

    // Виртуальная функция вывода
    virtual void print() const = 0;

    // Виртуальная функция получения типа
    virtual string getType() const = 0;

    // Виртуальный деструктор
    virtual ~LogEntry()
    {
    }
};


// ==========================================
// Класс INFO
// ==========================================

class InfoLog : public LogEntry
{
public:
    InfoLog(const string& msg)
        : LogEntry(msg)
    {
    }

    void print() const override
    {
        cout << "INFO: " << message << endl;
    }

    string getType() const override
    {
        return "INFO";
    }
};


// ==========================================
// Класс WARNING
// ==========================================

class WarningLog : public LogEntry
{
public:
    WarningLog(const string& msg)
        : LogEntry(msg)
    {
    }

    void print() const override
    {
        cout << "WARNING: " << message << endl;
    }

    string getType() const override
    {
        return "WARNING";
    }
};


// ==========================================
// Класс ERROR
// ==========================================

class ErrorLog : public LogEntry
{
public:
    ErrorLog(const string& msg)
        : LogEntry(msg)
    {
    }

    void print() const override
    {
        cout << "ERROR: " << message << endl;
    }

    string getType() const override
    {
        return "ERROR";
    }
};


// ==========================================
// Главная функция
// ==========================================

int main()
{
    setlocale(LC_ALL, "Russian");

    // Контейнер с указателями на базовый класс
    vector<LogEntry*> logs;

    // Открываем файл
    ifstream file("log.txt");

    if (!file.is_open())
    {
        cout << "Ошибка: не удалось открыть файл log.txt!" << endl;
        cout << "Убедитесь, что файл находится рядом с программой." << endl;

        return 1;
    }

    string line;

    // Считываем файл построчно
    while (getline(file, line))
    {
        // Пропускаем пустые строки
        if (line.empty())
        {
            continue;
        }

        // Проверяем тип записи
        if (line.rfind("INFO:", 0) == 0)
        {
            string message = line.substr(5);

            // Убираем пробел после :
            if (!message.empty() && message[0] == ' ')
            {
                message.erase(0, 1);
            }

            logs.push_back(new InfoLog(message));
        }
        else if (line.rfind("WARNING:", 0) == 0)
        {
            string message = line.substr(8);

            // Убираем пробел после :
            if (!message.empty() && message[0] == ' ')
            {
                message.erase(0, 1);
            }

            logs.push_back(new WarningLog(message));
        }
        else if (line.rfind("ERROR:", 0) == 0)
        {
            string message = line.substr(6);

            // Убираем пробел после :
            if (!message.empty() && message[0] == ' ')
            {
                message.erase(0, 1);
            }

            logs.push_back(new ErrorLog(message));
        }
        else
        {
            cout << "Предупреждение: неизвестный тип записи:" << endl;
            cout << line << endl;
        }
    }

    file.close();


    // ==========================================
    // Вывод всех записей
    // ==========================================

    cout << "==========================================" << endl;
    cout << "        АНАЛИЗ ЛОГ-ФАЙЛА" << endl;
    cout << "==========================================" << endl;

    cout << endl;

    cout << "Все записи:" << endl;
    cout << "------------------------------------------" << endl;

    // Полиморфный вызов print()
    for (LogEntry* log : logs)
    {
        log->print();
    }

    cout << endl;


    // ==========================================
    // Подсчёт количества записей
    // ==========================================

    int infoCount = 0;
    int warningCount = 0;
    int errorCount = 0;

    for (LogEntry* log : logs)
    {
        string type = log->getType();

        if (type == "INFO")
        {
            infoCount++;
        }
        else if (type == "WARNING")
        {
            warningCount++;
        }
        else if (type == "ERROR")
        {
            errorCount++;
        }
    }


    // ==========================================
    // Вывод статистики
    // ==========================================

    cout << "==========================================" << endl;
    cout << "              СТАТИСТИКА" << endl;
    cout << "==========================================" << endl;

    cout << "INFO: " << infoCount << endl;
    cout << "WARNING: " << warningCount << endl;
    cout << "ERROR: " << errorCount << endl;


    // ==========================================
    // Вывод только ошибок
    // ==========================================

    cout << endl;

    cout << "==========================================" << endl;
    cout << "                ОШИБКИ" << endl;
    cout << "==========================================" << endl;

    bool hasErrors = false;

    for (LogEntry* log : logs)
    {
        if (log->getType() == "ERROR")
        {
            log->print();
            hasErrors = true;
        }
    }

    if (!hasErrors)
    {
        cout << "Ошибок не найдено." << endl;
    }


    // ==========================================
    // Освобождение памяти
    // ==========================================

    for (LogEntry* log : logs)
    {
        delete log;
    }

    logs.clear();


    // ==========================================
    // Завершение программы
    // ==========================================

    cout << endl;
    cout << "==========================================" << endl;
    cout << "Анализ завершён." << endl;
    cout << "==========================================" << endl;

    return 0;
}

