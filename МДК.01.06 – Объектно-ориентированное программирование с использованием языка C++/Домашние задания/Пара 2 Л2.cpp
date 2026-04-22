
#include <iostream>
#include <locale>
#include <string>
using namespace std;
class Book {
private:
    int stran;
    string name;
public:
    Book() {
        stran = 0;
        name = "Книга";
    }
    Book(string bookName, int bookStran) {
        name = bookName;
        stran = bookStran;
    }
    int getSran()const {
        return stran;
    }
    void show_info() {
        cout << "Название: " << name << endl;
        cout << "Страниц: " << stran << endl;
    }


};

int main()
{
    setlocale(LC_ALL, "ru");
    Book book1;
    cout << "Книга 1:" << endl;
    book1.show_info();

    cout << "\n";

  
    Book book2("Война и мир", 1225);
    cout << "Книга 2:" << endl;
    book2.show_info();

    return 0;
    
}

