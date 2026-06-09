#include <iostream>
#include <vector>
#include <algorithm>
#include <chrono>
using namespace std;

vector<int> create_vector() {
    cout << "Creating a vector..." << endl;
    auto start = chrono::high_resolution_clock::now();

    vector<int> nums;

    for (int i = 0; i < 1000000; i++)
    {
        nums.push_back(i);
    }

    auto end = chrono::high_resolution_clock::now();
    auto duration = end - start;
    auto ms = chrono::duration_cast<chrono::milliseconds>(duration);
    cout << "Successfully! Wasted time: " << ms.count() << "ms." << endl;

    return nums;
}

void reverse_vector(vector<int>& nums) {
    cout << "Reversing a vector..." << endl;
    auto start = chrono::high_resolution_clock::now();

    reverse(nums.begin(), nums.end());

    auto end = chrono::high_resolution_clock::now();
    auto duration = end - start;
    auto ms = chrono::duration_cast<chrono::milliseconds>(duration);
    cout << "Successfully! Wasted time: " << ms.count() << "ms." << endl;

}

void sort_vector(vector<int>& nums) {
    cout << "Sorting a vector..." << endl;
    auto start = chrono::high_resolution_clock::now();

    sort(nums.begin(), nums.end());

    auto end = chrono::high_resolution_clock::now();
    auto duration = end - start;
    auto ms = chrono::duration_cast<chrono::milliseconds>(duration);
    cout << "Successfully! Wasted time: " << ms.count() << "ms." << endl;
}


int main()
{
    vector<int> million = create_vector();
    cout << endl;
    reverse_vector(million);
    sort_vector(million);
    cout << endl;

    cout << "RESULT: REVERSE OPERATION IS HAPPENING FASTER THAN SORT OPERATION\n"
        "REASON:\n"
        "REVERSE OPERATION IS USING O(N) LINEAR SEARCH - SWAPPING POSITIONS WITH 2 VALUES -> 1000000 ELEMENTS = 1000000 SWAP OPERATIONS\n"
        "SORT OPERATION IS USING O(LOG N) BINARY SEARCH - HAVE DIFFICUT ALGOTIRM -> 1000000 ELEMENTS = 20000000 ALGORITM OPERATIONS";
}