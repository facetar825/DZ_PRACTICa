#include <iostream>
#include <vector>
#include <numeric>  // accumulate, iota, partial_sum
#include <algorithm>
#include <functional> // std::multiplies

int main() {
    // Задание 1: accumulate для суммы и произведения
    std::cout << "Задание 1: accumulate (сумма и произведение)\n";
    std::vector<int> v1 = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 };

    // Сумма с accumulate
    int sum = std::accumulate(v1.begin(), v1.end(), 0);
    std::cout << "Сумма: " << sum << "\n";

    // Произведение с accumulate + лямбда
    int product = std::accumulate(v1.begin(), v1.end(), 1,
        [](int a, int b) { return a * b; });
    std::cout << "Произведение: " << product << "\n\n";


    // Задание 2: iota для заполнения вектора
    std::cout << "Задание 2: заполнение iota начиная с 5\n";
    std::vector<int> v2(15);
    std::iota(v2.begin(), v2.end(), 5); // заполняет 5,6,7,...,19

    std::cout << "v2: ";
    for (int x : v2)
        std::cout << x << " ";
    std::cout << "\n\n";


    // Задание 3: partial_sum для префиксных сумм
    std::cout << "Задание 3: partial_sum (префиксные суммы)\n";
    std::vector<int> prefix_sum(v2.size());

    std::partial_sum(v2.begin(), v2.end(), prefix_sum.begin());

    std::cout << "Префиксные суммы: ";
    for (int x : prefix_sum)
        std::cout << x << " ";
    std::cout << "\n";

    return 0;
}
