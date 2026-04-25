#include <iostream>
using namespace std;

// ========== Класс Array (Задания 1-2) ==========
class Array {
private:
    int arr[5];
    int size;

public:
    Array() : size(5) {
        for (int i = 0; i < size; i++) arr[i] = 0;
    }

    Array(int a0, int a1, int a2, int a3, int a4) : size(5) {
        arr[0] = a0; arr[1] = a1; arr[2] = a2; arr[3] = a3; arr[4] = a4;
    }

    int& operator[](int index) {
        if (index < 0 || index >= size) {
            cout << "Ошибка! Индекс " << index << " вне границ!" << endl;
            exit(1);
        }
        return arr[index];
    }

    const int& operator[](int index) const {
        if (index < 0 || index >= size) {
            cout << "Ошибка! Индекс " << index << " вне границ!" << endl;
            exit(1);
        }
        return arr[index];
    }

    void display() const {
        cout << "[";
        for (int i = 0; i < 5; i++) {
            cout << arr[i];
            if (i < 4) cout << ", ";
        }
        cout << "]" << endl;
    }
};

// ========== Класс Count (Задание 3) ==========
class Count {
private:
    int value;

public:
    Count() : value(0) {}
    Count(int v) : value(v) {}

    int getValue() const { return value; }

    // Префиксный ++
    Count& operator++() {
        value++;
        return *this;
    }

    // Постфиксный ++
    Count operator++(int) {
        Count temp = *this;
        value++;
        return temp;
    }

    // Префиксный --
    Count& operator--() {
        value--;
        return *this;
    }

    // Постфиксный --
    Count operator--(int) {
        Count temp = *this;
        value--;
        return temp;
    }

    void display() const {
        cout << "value = " << value << endl;
    }
};

// ========== Главная функция ==========
int main() {
    // Демонстрация Array
    cout << "=== Array ===" << endl;
    Array arr;
    arr[2] = 99;
    arr.display();
    cout << "arr[2] = " << arr[2] << endl;

    // Демонстрация Count
    cout << "\n=== Count ===" << endl;
    Count cnt(10);
    cnt.display();
    ++cnt;
    cout << "После ++cnt: "; cnt.display();
    cnt--;
    cout << "После cnt--: "; cnt.display();

    return 0;
}