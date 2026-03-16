//Задание 1
#include <iostream>
using namespace std;

class Student {
private:
    string name;
    int age;
    double grade;

public:
    Student(string name, int age, double grade) {
        this->name = name;
        this->age = age;
        this->grade = grade;
    }

    ~Student() {
        cout << "Student destroyed\n";
    }

    void setData(string name, int age, double grade) {
        this->name = name;
        this->age = age;
        this->grade = grade;
    }

    void printInfo() {
        cout << "Student Info\n";
        cout << "Name : " << name << endl;
        cout << "Age  : " << age << endl;
        cout << "Grade: " << grade << endl;
    }
};

int main() {

    Student s1("Alex", 20, 4.6);
    s1.printInfo();

    cout << "\nCopying student...\n";

    Student s2 = s1;
    s2.printInfo();

    return 0;
}

//Задание 2
#include <iostream>
using namespace std;

class Car {
public:
    string brand;

private:
    int year;

protected:
    int speed;

public:

    Car(string brand, int year, int speed) {
        this->brand = brand;
        this->year = year;
        this->speed = speed;
    }

    void setYear(int y) {
        this->year = y;
    }

    int getYear() {
        return year;
    }

    void setSpeed(int s) {
        this->speed = s;
    }

    int getSpeed() {
        return speed;
    }

    void printInfo() {
        cout << "----- Car Info -----\n";
        cout << "Brand: " << brand << endl;
        cout << "Year : " << year << endl;
        cout << "Speed: " << speed << endl;
    }
};

int main() {

    Car car1("Toyota", 2021, 180);

    car1.printInfo();

    cout << "\nUpdating values...\n";

    car1.setYear(2023);
    car1.setSpeed(200);

    car1.printInfo();

    return 0;
}

//Задание 3
#include <iostream>
using namespace std;

class Product {
private:
    string name;
    double price;
    int quantity;

public:

    Product(string name, double price, int quantity) {
        this->name = name;
        this->price = price;
        this->quantity = quantity;
    }

    ~Product() {
        cout << "Product destroyed\n";
    }

    Product* setData(string name, double price, int quantity) {
        this->name = name;
        this->price = price;
        this->quantity = quantity;
        return this;
    }

    void printInfo() {
        cout << "----- Product Info -----\n";
        cout << "Name     : " << name << endl;
        cout << "Price    : " << price << endl;
        cout << "Quantity : " << quantity << endl;
    }

    void buy(int amount) {

        if (amount <= quantity) {
            quantity -= amount;
            cout << "Purchased: " << amount << endl;
        }
        else {
            cout << "Not enough products in stock!\n";
        }
    }
};

int main() {

    Product p1("Laptop", 1500.0, 10);

    p1.printInfo();

    cout << endl;

    p1.buy(3);

    cout << endl;

    p1.printInfo();

    return 0;
}