

#include <iostream>

using namespace std;
class Car {
private:
	string model = "Audi";
public:
	int fuel = 20;
	int drive(int distance) {
		fuel -= (distance / 100);
		return fuel;
	};
	int refuel(int amount) {
		fuel += amount;
		return fuel;
	};
	int getFuel() {
		cout << fuel << endl;
		return fuel;
	};

};

int main() {
	Car car;
	car.drive(1000);
	car.getFuel();
	car.refuel(5);
	car.getFuel();


}
