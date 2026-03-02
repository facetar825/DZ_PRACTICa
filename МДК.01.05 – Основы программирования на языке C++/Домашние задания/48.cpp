#include <iostream>
#include <fstream>
#include <stdexcept>
#include <string>

// Задание 1 & 2: Функция деления с проверкой на 0
double divide(double a, double b) {
    if (b == 0.0) {
        throw std::runtime_error("Деление на ноль!");
    }
    return a / b;
}

// Задание 3: Чтение файла с обработкой ошибок
double read_and_average(const std::string& filename) {
    std::ifstream file(filename);
    if (!file.is_open()) {
        throw std::runtime_error("Не удалось открыть файл: " + filename);
    }

    double sum = 0.0;
    int count = 0;
    double num;

    while (file >> num) {
        sum += num;
        count++;
    }

    if (count == 0) {
        throw std::runtime_error("Файл пуст или не содержит чисел");
    }

    return sum / count;
}

// Задание 4: Функция с throw вместо return (-1)
int safe_sqrt(int x) {
    if (x < 0) {
        throw std::invalid_argument("Корень из отрицательного числа!");
    }
    return static_cast<int>(std::sqrt(x));
}

int main() {
    try {
        // Задание 1 & 2: Тестируем деление
        std::cout << "=== Задание 1 & 2: Деление ===\n";
        std::cout << "10 / 2 = " << divide(10.0, 2.0) << "\n";

        // Деление на ноль
        std::cout << "10 / 0 = ? ";
        std::cout << divide(10.0, 0.0) << "\n"; // выбросит исключение

    }
    catch (const std::runtime_error& e) {
        std::cout << "ОШИБКА: " << e.what() << "\n\n";
    }

    try {
        // Задание 3: Чтение файла с обработкой ошибок
        std::cout << "=== Задание 3: Чтение файла ===\n";
        double avg = read_and_average("numbers.txt");
        std::cout << "Среднее значение: " << avg << "\n";

    }
    catch (const std::runtime_error& e) {
        std::cout << "ОШИБКА чтения файла: " << e.what() << "\n\n";
    }

    try {
        // Задание 4: Замена return -1 на throw
        std::cout << "=== Задание 4: sqrt(-4) ===\n";
        std::cout << "sqrt(-4) = " << safe_sqrt(-4) << "\n";

    }
    catch (const std::invalid_argument& e) {
        std::cout << "ОШИБКА: " << e.what() << "\n\n";
    }

    // Задание 5: Цепочка вызовов с обработкой в main
    std::cout << "=== Задание 5: Цепочка вызовов ===\n";
    try {
        // Создаем цепочку: main -> process_data -> read_file -> divide
        std::cout << "Начинаем цепочку...\n";

        // Имитируем вложенные вызовы
        double result = process_data();

    }
    catch (const std::exception& e) {
        std::cout << "ПЕРЕХВАЧЕНО В MAIN: " << e.what() << "\n";
    }

    std::cout << "Программа завершена успешно!\n";
    return 0;
}

// Вспомогательные функции для цепочки вызовов (Задание 5)
double process_data() {
    try {
        return read_file_and_divide();
    }
    catch (...) {
        throw std::runtime_error("Ошибка в process_data");
    }
}

double read_file_and_divide() {
    try {
        // Имитируем чтение файла
        double data = read_numbers();
        return divide(data, 0.0); // здесь будет исключение
    }
    catch (...) {
        throw std::runtime_error("Ошибка в read_file_and_divide");
    }
}

double read_numbers() {
    return 42.0; // тестовые данные
}
