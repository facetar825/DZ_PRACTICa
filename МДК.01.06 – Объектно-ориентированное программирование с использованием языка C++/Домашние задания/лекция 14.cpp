
#include <iostream>
#include <string>
using namespace std;
class Animal {
public:
	virtual void sound(){
		cout << "Звук животного" << endl;
	}
	Animal(string name) {
		cout << "Animal " << name << endl;
	};
};
class Pet {
	
};
class Dog : public Animal {
public:
	void sound() override {
		cout << "Гва" << endl;
	}
	Dog(string name):
		Animal(name) {
		cout << "Дог создан" << endl;
	};
};
class Character {
private:
	string name;
	int hp;
	int dmg;
public:
	Character(string name, int hp, int dmg)
		: name(name), hp(hp), dmg(dmg) {
	};
	virtual int attack() {
		cout << name << " атакует" << endl;
		return dmg;  
	};
	string getName() { return name; }
	int getHp() { return hp; }
	int getDmg() { return dmg; }

	void takeDamage(int damage) {
		hp -= damage;
		if (hp < 0) hp = 0;
		cout << name << " получил " << damage << " урона. Осталось HP: " << hp << endl;
	};
};
class Mage : public Character {
private:
	string nameSpell;
public:
	Mage(string name, int hp, int dmg, string nameSpell)
		: Character(name, hp, dmg), nameSpell(nameSpell) {
	};

	int attack() override {
		cout << getName() << " (Маг) атакует заклинанием " << endl;
		return getDmg();
	};

	void castSpell() {
		cout << getName() << " готовит заклинание: " << nameSpell << "!" << endl;
	};
};
class Warrior : public Character {
private:
	int armor;
public:
	Warrior(string name, int hp, int dmg, int armor)
		: Character(name, hp, dmg), armor(armor) {
	};

	int attack() override {
		cout << getName() << " (Воин) наносит " << getDmg() << " урона мечом!" << endl;
		return getDmg();
	};

	void slash() {
		cout << getName() << " использует Слэш  урон по всем врагам " << armor << " брони" << endl;
	};

	int getArmor() { return armor; };
};
int main() {
	setlocale(LC_ALL, "ru");


	Warrior warrior("Войни", 100, 25, 50);
	Mage mage("vfu", 80, 30, "Огненный шар");


	warrior.attack();
	mage.attack();


	warrior.slash();
	mage.castSpell();


	Character* characters[2];
	characters[0] = &warrior;
	characters[1] = &mage;

	for (int i = 0; i < 2; i++) {
		characters[i]->attack();
	};



