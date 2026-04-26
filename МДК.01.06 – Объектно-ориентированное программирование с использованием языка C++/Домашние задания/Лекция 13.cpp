
#include <iostream>
using namespace std;
class Base {
public:
    int a;
protected:
    int b;
private:
    int c;
};
class Engine {
public:
    void start() {

    };
};
class Car : private Engine {
public:
    void run() {
        start();
    };
};
class Derived : public Base {
public:
    void set() {
        b = 10;
    };
};
class Device {
private:
    string name;
    bool puwer;
public:
    Device(bool puwer, string name) {
        this->name = name;
        this->puwer = puwer;
    };
    bool trunOn() {
        cout << name <<  " Включен" << endl;
        return puwer = true;
    };
    bool trunOff() {
        cout << name << " Отключен" << endl;
        return puwer = false;
    };
    string getName() {
        return name;
    };
};
class Light : public Device {
public:
    Light(bool puwer, string name)
        : Device(puwer, name) {};
    bool trunOn() {
        cout << getName() << " свет  Включен" << endl;
        return Device::trunOn();
    };
    bool trunOff() {
        cout << getName() << " свет Отключен" << endl;
        return Device::trunOff();
    }      
};
class Thermostat : private Device {
public:
    Thermostat(bool puwer, string name) : Device(puwer, name) {};
    void On() {
        trunOn();
    };
    void Off() {
        trunOff();
    }
};
int main()
{
    setlocale(LC_ALL, "ru");
    Light ligth(true, "Люстра");
    ligth.trunOn();
    ligth.trunOff();
    cout << endl;


    Thermostat thermo(false, "Термостат");
    thermo.On();
    thermo.Off();
}

