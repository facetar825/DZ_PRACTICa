#include <iostream>
using namespace std;

class Point {
private:
    double x;
    double y;

public:
    // Конструкторы
    Point() : x(0), y(0) {}
    Point(double x, double y) : x(x), y(y) {}

    // Геттеры и сеттеры
    double getX() const { return x; }
    double getY() const { return y; }
    void setX(double x) { this->x = x; }
    void setY(double y) { this->y = y; }

    // Задание 1: operator+ (сложение координат)
    Point operator+(const Point& other) const {
        return Point(x + other.x, y + other.y);
    }

    // Задание 1: operator- (вычитание координат)
    Point operator-(const Point& other) const {
        return Point(x - other.x, y - other.y);
    }

    // Задание 2: operator== (проверка равенства)
    bool operator==(const Point& other) const {
        return (x == other.x && y == other.y);
    }

    // Задание 3: operator<< (вывод в поток) - ДРУЖЕСТВЕННАЯ ФУНКЦИЯ
    friend ostream& operator<<(ostream& os, const Point& point);
};

// Задание 3: Реализация оператора вывода (вне класса)
ostream& operator<<(ostream& os, const Point& point) {
    os << "(" << point.x << "; " << point.y << ")";
    return os;
}

// Демонстрация работы всех операторов
int main() {
    cout << "=== Создание точек ===" << endl;
    Point p1(3, 5);
    Point p2(2, 4);
    Point p3;

    cout << "p1 = " << p1 << endl;
    cout << "p2 = " << p2 << endl;
    cout << "p3 = " << p3 << endl;
    cout << endl;

    // Задание 1: Проверка сложения
    cout << "=== Сложение (operator+) ===" << endl;
    Point sum = p1 + p2;
    cout << p1 << " + " << p2 << " = " << sum << endl;
    cout << endl;

    // Задание 1: Проверка вычитания
    cout << "=== Вычитание (operator-) ===" << endl;
    Point diff = p1 - p2;
    cout << p1 << " - " << p2 << " = " << diff << endl;
    cout << endl;

    // Задание 2: Проверка равенства
    cout << "=== Сравнение (operator==) ===" << endl;
    Point p4(3, 5);  // Такая же, как p1

    cout << p1 << " == " << p2 << " ? " << (p1 == p2 ? "Да" : "Нет") << endl;
    cout << p1 << " == " << p4 << " ? " << (p1 == p4 ? "Да" : "Нет") << endl;
    cout << endl;

    // Дополнительная демонстрация цепочек операций
    cout << "=== Цепочки операций ===" << endl;
    Point result = p1 + p2 - p4;
    cout << p1 << " + " << p2 << " - " << p4 << " = " << result << endl;

    return 0;
}