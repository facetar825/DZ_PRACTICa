#include <iostream>
#include <fstream>
#include <vector>
#include <string>
#include <algorithm>
#include <cctype>

int main() {
    // Создаем тестовый файл для демонстрации
    std::ofstream test_file("test.txt");
    test_file << "1 2 3 4 5\n";
    test_file << "hello\n";
    test_file << "world\n";
    test_file << "123 456\n";
    test_file << "programming\n";
    test_file.close();

    // Задание 1: Прочитать файл с числами и вывести среднее значение
    std::cout << "Задание 1: среднее значение чисел из файла\n";
    {
        std::ifstream file("test.txt");
        double sum = 0.0;
        int count = 0;
        double num;

        while (file >> num) {
            sum += num;
            count++;
        }

        if (count > 0)
            std::cout << "Среднее: " << sum / count << "\n\n";
        else
            std::cout << "Чисел не найдено\n\n";
    }

    // Задание 2: Посчитать количество строк в файле
    std::cout << "Задание 2: количество строк в файле\n";
    {
        std::ifstream file("test.txt");
        std::string line;
        int line_count = 0;

        while (std::getline(file, line))
            line_count++;

        std::cout << "Строк: " << line_count << "\n\n";
    }

    // Задание 3: Найти самую длинную строку
    std::cout << "Задание 3: самая длинная строка\n";
    {
        std::ifstream file("test.txt");
        std::string line, longest;
        int max_len = 0;

        while (std::getline(file, line)) {
            if (line.length() > max_len) {
                max_len = line.length();
                longest = line;
            }
        }

        std::cout << "Самая длинная: '" << longest << "' (" << max_len << " символов)\n\n";
    }

    // Задание 4: Скопировать содержимое одного файла в другой
    std::cout << "Задание 4: копирование файла\n";
    {
        std::ifstream src("test.txt");
        std::ofstream dst("copy.txt");
        std::string line;

        while (std::getline(src, line))
            dst << line << "\n";

        std::cout << "Файл скопирован в copy.txt\n\n";
    }

    // Задание 5: Заменить пробелы на подчеркивания
    std::cout << "Задание 5: пробелы -> подчеркивания\n";
    {
        std::ifstream src("test.txt");
        std::ofstream dst("no_spaces.txt");
        std::string line;

        while (std::getline(src, line)) {
            for (char& c : line) {
                if (c == ' ')
                    c = '_';
            }
            dst << line << "\n";
        }

        std::cout << "Результат записан в no_spaces.txt\n";
    }

    return 0;
}
