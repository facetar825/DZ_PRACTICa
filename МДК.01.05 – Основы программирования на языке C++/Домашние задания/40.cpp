#include <iostream>
#include <vector>
#include <string>
#include <algorithm>
#include <limits>

int main()
{
    // Задание 1: Удалить все отрицательные числа из vector (remove_if)
    std::cout << "Задание 1: удаление отрицательных чисел\n";
    std::vector<int> v1 = { 5, -3, 8, -1, 0, 4, -7 };

    std::cout << "До: ";
    for (int x : v1)
        std::cout << x << " ";
    std::cout << "\n";

    v1.erase(
        std::remove_if(v1.begin(), v1.end(), [](int x) { return x < 0; }),
        v1.end()
    );

    std::cout << "После: ";
    for (int x : v1)
        std::cout << x << " ";
    std::cout << "\n\n";


    // Задание 2: найти второй по величине элемент в vector
    std::cout << "Задание 2: второй по величине элемент\n";
    std::vector<int> v2 = { 10, 3, 15, 8, 15, 2 };

    if (v2.size() < 2)
    {
        std::cout << "Недостаточно элементов\n\n";
        return 1;
    }

    // сортируем по убыванию и убираем дубли
    std::sort(v2.begin(), v2.end(), std::greater<int>());
    v2.erase(
        std::unique(v2.begin(), v2.end()),
        v2.end()
    );

    if (v2.size() < 2)
    {
        std::cout << "Нет второго по величине\n\n";
    }
    else
    {
        std::cout << "Второй по величине: " << v2[1] << "\n\n";
    }


    // Задание 3: отсортировать строку по алфавиту
    std::cout << "Задание 3: сортировка строки по алфавиту\n";
    std::string s = "programming";

    std::cout << "До: " << s << "\n";

    std::sort(s.begin(), s.end());

    std::cout << "После: " << s << "\n"; // aagimmnoprr

    return 0;
}
