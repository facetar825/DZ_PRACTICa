#include <iostream>
#include <vector>
#include <string>
#include <algorithm>
#include <numeric> // для std::accumulate

int main() {
    // Задание 1: Посчитать количество отрицательных элементов в vector
    std::cout << "Задание 1: количество отрицательных элементов\n";
    std::vector<int> v1 = { 5, -3, 8, -1, 0, 4, -7 };

    int neg_count = 0;
    for (int x : v1)
        if (x < 0) neg_count++;

    // Альтернатива с count_if:
    // int neg_count = std::count_if(v1.begin(), v1.end(), [](int x){ return x < 0; });

    std::cout << "Количество отрицательных: " << neg_count << "\n\n";


    // Задание 2: Удалить все чётные числа
    std::cout << "Задание 2: удаление чётных чисел\n";
    std::vector<int> v2 = { 1, 2, 3, 4, 5, 6, 7, 8 };

    std::cout << "До: ";
    for (int x : v2)
        std::cout << x << " ";
    std::cout << "\n";

    v2.erase(
        std::remove_if(v2.begin(), v2.end(), [](int x) { return x % 2 == 0; }),
        v2.end()
    );

    std::cout << "После: ";
    for (int x : v2)
        std::cout << x << " ";
    std::cout << "\n\n";


    // Задание 3: Проверить, что все элементы положительные
    std::cout << "Задание 3: все элементы положительные?\n";
    std::vector<int> v3 = { 1, 2, 3, 4, 5 };

    bool all_positive = std::all_of(v3.begin(), v3.end(), [](int x) { return x > 0; });
    std::cout << "Все положительные: " << (all_positive ? "ДА" : "НЕТ") << "\n\n";


    // Задание 4: Найти минимальный элемент и заменить его на 0
    std::cout << "Задание 4: заменить минимальный элемент на 0\n";
    std::vector<int> v4 = { 10, 3, 15, 8, 2, 7 };

    std::cout << "До: ";
    for (int x : v4)
        std::cout << x << " ";
    std::cout << "\n";

    auto it = std::min_element(v4.begin(), v4.end());
    *it = 0;

    std::cout << "После: ";
    for (int x : v4)
        std::cout << x << " ";
    std::cout << "\n\n";


    // Задание 5: Отсортировать строку в обратном алфавитном порядке
    std::cout << "Задание 5: сортировка строки в обратном порядке\n";
    std::string s = "programming";

    std::cout << "До: " << s << "\n";

    std::sort(s.begin(), s.end(), std::greater<char>());

    std::cout << "После: " << s << "\n"; // rrpomnimmgaa

    return 0;
}
