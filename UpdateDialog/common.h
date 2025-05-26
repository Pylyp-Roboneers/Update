#ifndef COMMON_FUNCTIONS_PV
#define COMMON_FUNCTIONS_PV
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <chrono>
#include <unistd.h>
#include <ctime>
#include <fstream>
#include <string>
using namespace std;

// returns machine timestamp in nanoseconds
static inline unsigned long long int getTimeNS()
{
    return (std::chrono::duration_cast<std::chrono::nanoseconds>(std::chrono::system_clock::now().time_since_epoch())).count();
}
// returns time from first function launch in seconds
static inline double getTimeSec()
{
    static unsigned long long int time0 = getTimeNS();
    return 1e-9 * double( getTimeNS() - time0);
}
// Function prints logs in file similar to printf specification
// It is using for logging without terminal (console)
extern inline int printLog(const char* format, ...) 
{
    va_list vl;
    va_start(vl, format);
    static bool FirstTime = true;
    FILE* LogF = fopen("yLog.txt", (FirstTime)?"w":"a"); FirstTime = false;
    auto ret = vfprintf(LogF, format, vl);
    fclose(LogF);
    va_end(vl);
    return ret;
}
// Function finds string in fike containing "Desct" 
// and returs string from "Desct" end to the string end.
// Used to find value of set in shell file
extern inline string findInFile(const char* FileName, const char* Desct)
{
    ifstream file(FileName);
    if(!file.good()) {printLog("\nfindInFile: Bad file %s/", FileName); return string("NONE"); };
    string line, dest(Desct);
    while(!file.eof())
    {
        std::getline(file, line); // printLog("\nd2 Extract: %s", line.c_str());
        if( line.find(dest) != std::string::npos) 
        {
            return line.substr(dest.size(),line.size());
        }
    }
    return string("NONE");
}
#endif
