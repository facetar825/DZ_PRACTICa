
#include <iostream>
#include <string>
using namespace std;
class Engine {
public:
    void start() {
        cout << "Двигатель запущен" << endl;
    }
};
class Car {
private:
    Engine* engine;
public:
    Car(Engine* engine) {
        this->engine = engine;
    }

    void startCar() {
        engine->start();
    }
};
class Author {
private:
    string name;

public:
    Author(string name) {
        this->name = name;
    }
    string getName() {
        return name;
    }
};
class Book {
private:
    string title;
    Author author;

public:
    Book(string title, string authorName)
        :author(authorName) {
        this->title = title;
    };

    void print() {
        cout << title << " - " << author.getName() << endl;
    }
};

class Processor {
private:
    string CPUmodel;
    double ggrs;
public:
    Processor(string CPUmodel, double ggrs) : CPUmodel(CPUmodel), ggrs(ggrs) {
        cout << "Процессор" << CPUmodel << " (" << ggrs << " ГГц создан" << endl;
    };
    void start() {
        cout << "Процессор работает" << endl;
    };
};

class Ram {
private:
    double gb;
    string type;
public:
    Ram(double gb, string type) : gb(gb), type(type){
        cout << "Оперативаня пямять  на " << gb << " типа " << type << " Создана" << endl;

    }
    void start() {
        cout << "Пямать работает" << endl;
    };
};

class GPU {
private:
    string gpuModel;
    int vram;

public:
    GPU(string gpuModel, int vram) : gpuModel(gpuModel), vram(vram) {
        cout << "Видеокарта модели " << gpuModel <<" " << vram << endl;
    }
    void start() {
        cout << "Видеокарта работает" << endl;
    };
};

class Kupyter {
private:
    Processor cpu;
    Ram ram;
    GPU gpu;

    string kupyterName;
public:

    Kupyter(string kupyterName, string CPUmodel, double ggrs, double gb, string type, string gpuModel, int vram)
        : kupyterName(kupyterName),
        cpu(CPUmodel, ggrs),
        ram(gb, type),
        gpu(gpuModel, vram) {

    };
    
    void start() {
        cpu.start();
        ram.start();
        gpu.start();
        cout << "Копьютер работает" << endl;
        
    };

};
int main()
{

    

}

