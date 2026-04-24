

#include <iostream>
using namespace std;

class Student {
private:
    static int count;
    
public:
    

    Student() {
        count++;
    };

    static int getCount() {
        return count;
    };

};
class MathUtils {

public:
    static int add(int a, int b) {
        return a + b;
    };
    // Я НЕ ЗНАЮ ЧТО ТАКОЕ САБ ДУМАЮ ЭТО ДЕЛЕНИЕ 
    static int sub(int a, int b) {
        return a / b;
    };
    //я не особо понял зачем статик 
    static int mul(int a, int b) {
        return a * b;
    };
};
class Test {
private:
    int value;
public:

    static void print() {

    };
};
class Counter {
    
private:
    static int count;
public:

    Counter() {
        count++;
    };

    static int getCount() {
        return count;
    };

};
class Product {
private:
    // а зачем цена и имя
    string name;
    double price;
    static int productCount;

public:
    void setName(string name) {
        this->name = name;
    };
    void setPrice(double price) {
        this->price = price;
    };

    Product() {
        productCount++;
    };
    static int getCount() {
        return productCount;
    };
    string getName() {
        return name;
    };

    double getPrice() {
        return price;
    };
};
int Product::productCount = 0;
int Counter::count = 0;
int Student::count = 0;
int main()
{
    setlocale(LC_ALL, "ru");
    // прикол я не знал если без скобок написать то адрес памяти показывает минут 5 думал что не так 
    cout << Student::getCount() << endl;
    Student s1;
    Student s2;
    Student s3;
    cout <<"Количество обьектов"<< Student::getCount() << endl;
   

    MathUtils M1;
    int result = MathUtils::add(5, 3);
    cout <<"Слажение "<< M1.add(2, 5) << endl;
    cout <<"Умножение "<< M1.mul(2, 10) << endl;
    cout <<"Деление " << M1.sub(10, 2) << endl;
    //саб наверно сабдивижон в бледере это деление

    Counter a;
    Counter b;
    Counter c;

    cout << a.getCount() << endl;
    cout << Counter::getCount() << endl;


    Product p1;
    Product p2;
    Product p3;
    cout << "Количетсво продукта " << Product::getCount() << endl;
    p1.setName("Кукр");
    p1.setPrice(200.12);
    cout << p1.getName() << endl;
    cout << p1.getPrice() << endl;




}

