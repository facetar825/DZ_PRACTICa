#include <iostream>
#include <fstream>
#include <string>
#include <vector>

using namespace std;
ifstream file("log.txt");

bool isInfo(const string& line)
{
    return line.find("INFO") != string::npos;

}

bool isWarning(const string& line)
{
    return line.find("WARNING") != string::npos;
}

bool isError(const string& line)
{
    return line.find("ERROR") != string::npos;
}



int main() {
    int info_counter = 0;
    int warning_counter = 0;
    int error_counter = 0;
    string line;
    vector<string> error_log;

    if (!file) {
        cout << "File log.txt is not found";
        return 0;
    }
    else
    {
        cout << "Statistic:" << endl;
        while (getline(file, line))
        {
            if (isInfo(line)) {
                info_counter++;
            }
            else if (isWarning(line)) {
                warning_counter++;
            }
            else if (isError(line)) {
                error_counter++;
                error_log.push_back(line);
            }
        }
        cout << "INFO: " << info_counter << endl;
        cout << "WARNING: " << warning_counter << endl;
        cout << "ERROR: " << error_counter << endl;

        cout << "\nErrors:" << endl;
        for (string e : error_log) {
            cout << e << endl;
        }
    }
    file.close();
}