
#include <iostream>
using namespace std;
class Person {
private:
    int age;

public:
    void setAge(int a) {
        if (a >= 0 && a <= 120) {
            age = a;
        }
    };
    int getAge() {
        return age;
    };
};
class StudentP {
private:
    string name;
public:

    void setName(string name) {
        this->name = name;

    };
};
class Product {
private:
    string name;
    double price;

public:

    void setName(string name) {
        this->name = name;
    };

    void setPrice(double price) {
        if (price > 0) {
            this->price = price;
        }
    };
    string getName() {
        return name;
    };
    double getPrice() {
        return price;
    };

};

class Clothes {
public:
    enum class TypeClothes { TSHIRT, JEANS, COAT, SUIT, SHORTS };

private:
    //Я тут плохо понимать  что на было сделать и я поросил ии надеюсь правильно с эти тип одежды
    
    TypeClothes typeClothes;
    string name;
    double price;
    int size;
    string color;
public:
    void setName(string name) {
        this->name = name;
    };
    void setPrice(double price) {
        if (price > 0) {
            this->price = price;
        };
    };
    void setType(TypeClothes newType) {
       typeClothes = newType;
    };
    void setCategory(string newCategory) {
        // При установке категории нужно выбрать подходящий тип одежды
        if (newCategory == "Повседневная") {
            typeClothes = TypeClothes::TSHIRT;  // или JEANS
        }
        else if (newCategory == "Верхняя одежда") {
            typeClothes = TypeClothes::COAT;
        }
        else if (newCategory == "Деловая") {
            typeClothes = TypeClothes::SUIT;
        }
        else if (newCategory == "Спортивная") {
            typeClothes = TypeClothes::SHORTS;
        }
    };
    void setSize(int size) {
        this->size = size;
    };
    void setColor(string color) {
        this->color = color;
    };
    string getCategory() {
        // Вычисляем категорию на основе typeClothes
        switch (typeClothes) {
        case TypeClothes::TSHIRT:
        case TypeClothes::JEANS:
            return "Повседневная";
        case TypeClothes::COAT:
            return "Верхняя одежда";
        case TypeClothes::SUIT:
            return "Деловая";
        case TypeClothes::SHORTS:
            return "Спортивная";
        default:
            return "Не определена";
        }
    };
    string getName() {
        return name;
    };
    double getPrice() {
        return price;
    };
    int getSize() {
        return size;
    };
    string getColor() {
        return color;
    }


};

int main()
{
    setlocale(LC_ALL, "ru");
    Clothes item;

    item.setName("Футболка");
    item.setPrice(1500);
    item.setType(Clothes::TypeClothes::TSHIRT);
    item.setSize(42);
    item.setColor("Красный");

    cout << item.getName() << endl;      
    cout << item.getPrice() << endl;    
    cout << item.getCategory() << endl; 

    return 0;


}

