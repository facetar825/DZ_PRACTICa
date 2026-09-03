#include <iostream>
#include <windows.h>

using namespace std;

void waiting(int mins){
    cout << "Ваша пицца начинает готовится!\nБудет готова через секунду..." << endl;
    Sleep(1000);
    cout << "Пицца готова! Ожидайте доставку через " << mins << " минут\n"; 
}

void request(string pizza, int price, int mins){
    int y_n;
    cout << "Цена пиццы: " << price << "\n";
    cout << "Оформлять заказ? (1 - да, 2 - нет): ";
    cin >> y_n;
    switch(y_n){
        case 1:
            cout << "\nОформление заказа пиццы: " << pizza << endl;
            cout << "Произведение оплаты на сумму " << price << "...\n";
            waiting(mins);
            break;
        case 2:
            cout << "Заказ отменен\n";
    }
}

int main(){
    int action;
    string p = "Пепперони";
    string c = "4 сыра";
    string m = "Мясная";

    while(true){
        try{
        cout << endl;
        cout << "=========PIZZERIA=========\n1. Быстро заказать пиццу\n2. Просмотр меню\nВыберите действие: ";
        cin >> action;

        switch (action)
        {
        case 1:
            cout << "\nБыстрый заказ пиццы:\n1. Пепперони\n2. 4 сыра\n3. Мясная" << endl;

            int choice;
            cout << "\nВыберите пиццу по номеру: ";
            cin >> choice;

            switch(choice){
                case 1:
                    request(p, 400, 30);
                    break;
                case 2:
                    request(c, 300, 20);
                    break;
                case 3:
                    request(m, 500, 40);
                    break;
            }
            break;

        case 2:
            cout << "\nМеню:\n1. Пепперони\n2. 4 сыра\n3. Цыпленок барбекю\n4. Мясная\n5. Маргарита";
            break;


        default:
            cout << "Неверный ввод!\n";
            break;
        }
    }

    catch(const exception& e){
        cout << "Ошибка: " << e.what();
        }
    }
}