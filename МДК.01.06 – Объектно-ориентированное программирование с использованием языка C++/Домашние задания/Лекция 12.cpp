
#include <iostream>
using namespace std;
class Animal {
public:
    Animal(string name) {
        cout << "Animal создан " << endl;
    }
    void eat() {
        cout << "Животное ест" << endl;
    };
    void sound() {
        cout << "звук животного" << endl;
    }
    
};
class Dog : public Animal {
public:
    
    
    Dog(string name) : Animal(name) {
        cout << "Dog создан" << endl;
    };
    void sound() {
        cout << "Гав" << endl;
    }
};
class Person {
protected:
    string name;

public:
    Person(string name) {
        this->name = name;
    }
};
class Student : public Person {
private:
    int grade;
public:
    Student(string name, int grade)
        : Person(name) {
        this->grade = grade;
    }
    void print() {
        cout << name << " - " << grade << endl;
    }
};
class Employee {
private:
    string name;
    int experience;
public:
    Employee(string name, int experience) {
        this->name = name;
        this->experience = experience;
    }
    void work() {
        cout << "Работает " << name << endl;
    }
    string getName() {
        return name;
    };
    int getExperience() {
        return experience;
    };
};
class Manager : public Employee {
private:
    int teams;
public:
    Manager(string name, int experience, int teams)
        : Employee(name, experience) {
        this->teams = teams;
    };
    // 10 минут потратил на то что бы понять что не так искал в конспекте в инете как деле переоброзование 
    //озкозалось что не привильно написал get  gat 
    void work() {
        cout << "Менежер " << getName() << " Управляет" << teams << " Человек" << endl;
    };
    void manager() {
        cout << getName() << "Что то особеное" << endl;
    }

};
class Developer : public Employee{
private:
    string stage;
public:
    Developer(string name, int experience, string stage)
        :Employee(name, experience) {
        this->stage = stage;
    };
    void work() {
        cout << "Работник " << getName() << "Работает на этапе " << stage << endl;
    };
    void perekur() {
        cout << getName() << " Ушол курить";
    }

};
int main()
{
    setlocale(LC_ALL, "ru");
    Dog dog("Пес ");
    dog.sound();
    
    
}

