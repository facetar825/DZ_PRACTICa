/*
Приложение: Библиотека фильмов
Основные функции:
- Просмотр каталога;
- Добавления фильма в каталог;
- Удаление фильма из каталога;
- Поиск фильма по названию;
- Редактирование фильма;        // НОВАЯ ФУНКЦИЯ
- Фильтрация по жанрам;         // НОВАЯ ФУНКЦИЯ
*/

#include <iostream>
#include <string>     
#include <vector>
#include <algorithm>
using namespace std;

/// @brief Фильм
class Movie {
public:
    // Конструктор
    Movie(string title, string genre, double rating, int duration) {
        this->title = title;
        this->genre = genre;
        this->rating = rating;
        this->duration = duration;
    }

    // Геттеры
    string getTitle() { return title; };
    string getGenre() { return genre; };
    double getRating() { return rating; };
    int getDuration() { return duration; };

    // Сеттеры (для редактирования)
    void setTitle(string newTitle) { title = newTitle; };
    void setGenre(string newGenre) { genre = newGenre; };
    void setRating(double newRating) { rating = newRating; };
    void setDuration(int newDuration) { duration = newDuration; };

    /// @brief Вывод информации о фильме
    void display() {
        cout << "Фильм – " << title << "\nЖанр – " << genre << "\nРейтинг – " << rating << "\nДлительность – " << duration << "\n" << endl;
    }

private:
    string title;     // Название фильма
    string genre;     // Жанр фильма
    double rating;    // Рейтинг фильма
    int duration;     // Длительность в минутах
};

/// @brief Каталог фильмов
class Catalog {
public:
    /// @brief Добавление фильма
    void addMovie(string title, string genre, double rating, int duration) {
        movies.push_back(Movie(title, genre, rating, duration));
        cout << "Фильм добавлен!\n" << endl;
    }

    /// @brief Удаление фильма
    void removeMovie(string title) {
        for (int i = 0; i < movies.size(); i++) {
            if (movies[i].getTitle() == title) {
                movies.erase(movies.begin() + i);
                cout << "Фильм удалён!\n" << endl;
                return;
            }
        }
        cout << "Фильм не найден!\n" << endl;
    }

    /// @brief Поиск по названию
    void findByTitle(string title) {
        bool found = false;
        for (Movie movie : movies) {
            if (movie.getTitle() == title) {
                movie.display();
                found = true;
            }
        }
        if (!found) {
            cout << "Фильм не найден!\n" << endl;
        }
    };
    void editMovie(string title) {
        for (int i = 0; i < movies.size(); i++) {
            if (movies[i].getTitle() == title) {
                movies[i].display();
                cout << "Найден фильм" << endl;

                string newTitle;
                string newGenre;
                double newReting;
                int newDuration;


                cout << "Введите новое название фильма";

                getline(cin, newTitle);
                if (!newTitle.empty()) {
                    movies[i].setTitle(newTitle);
                };
                cout << "Введите новое название жанар";

                getline(cin, newGenre);
                if (!newGenre.empty()) {
                    movies[i].setTitle(newGenre);
                };

                cout << "Введите новой ретинг ";
                cin >> newReting;
                if (newReting > 0) {
                    movies[i].setRating(newReting);
                }

                cout << "Введите новую длительность";
                cin >> newDuration;
                if (newDuration > 0) {
                    movies[i].setRating(newReting);
                };

                cout << "Фильм отредактор" << endl;
                cin.ignore();
                return;



            };
        };
        cout << "Фильм не найден" << endl;
    };
    void filterByGenre(string genre) {
        bool found = false;
        cout << "Фильм в жанре: " << genre << endl;

        for (Movie movie : movies) {

            string movieGenre = movie.getGenre();
            string searchGenre = genre;


            transform(movieGenre.begin(), movieGenre.end(), movieGenre.begin(), ::tolower);
            transform(searchGenre.begin(), searchGenre.end(), searchGenre.begin(), ::tolower);

            if (movieGenre == searchGenre) {
                movie.display();
                found = true;
            };
        }
        if (!found) {
            cout << "Фильм в жанре: " << genre << "не найдены "<< endl;
        }
    }
    


    
    void showMovies() {
        if (movies.empty()) {
            cout << "Каталог пуст!\n" << endl;
            return;
        }

        cout << "\n=== ВСЕ ФИЛЬМЫ ===\n" << endl;
        for (Movie movie : movies) {
            movie.display();
        }
    }

private:
    vector<Movie> movies;
};

int main() {
    setlocale(LC_ALL, "ru");
    Catalog catalog;
    int choice;

    do {
        cout << "\n========== MOVIES LIBRARY ==========" << endl;
        cout << "1. Показать все фильмы" << endl;
        cout << "2. Добавить фильм" << endl;
        cout << "3. Найти фильм по названию" << endl;
        cout << "4. Удалить фильм" << endl;
        cout << "5. Редактировать фильм" << endl;      // НОВЫЙ ПУНКТ
        cout << "6. Фильтровать по жанру" << endl;     // НОВЫЙ ПУНКТ
        cout << "0. Выход" << endl;
        cout << "=====================================" << endl;
        cout << "Выбор: ";
        cin >> choice;

        cin.ignore(); // Очистка буфера

        switch (choice) {

        case 1:
            catalog.showMovies();
            break;

        case 2: {
            string title, genre;
            double rating;
            int duration;

            cout << "Название: ";
            getline(cin, title);

            cout << "Жанр: ";
            getline(cin, genre);

            cout << "Рейтинг (0-10): ";
            cin >> rating;

            cout << "Длительность (минуты): ";
            cin >> duration;

            catalog.addMovie(title, genre, rating, duration);
            cin.ignore(); // Очистка буфера
            break;
        }

        case 3: {
            string title;
            cout << "Введите название: ";
            getline(cin, title);
            catalog.findByTitle(title);
            break;
        }

        case 4: {
            string title;
            cout << "Введите название: ";
            getline(cin, title);
            catalog.removeMovie(title);
            break;
        }

        case 5: {  // НОВЫЙ КЕЙС: Редактирование
            string title;
            cout << "Введите название фильма для редактирования: ";
            getline(cin, title);
            catalog.editMovie(title);
            break;
        }

        case 6: {  // НОВЫЙ КЕЙС: Фильтрация по жанру
            string genre;
            cout << "Введите жанр для поиска: ";
            getline(cin, genre);
            catalog.filterByGenre(genre);
            break;
        }

        case 0:
            cout << "До свидания!" << endl;
            break;

        default:
            cout << "Неверный выбор! Попробуйте снова." << endl;
        }
    } while (choice != 0);

    return 0;
}