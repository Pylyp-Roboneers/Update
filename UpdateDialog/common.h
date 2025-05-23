#ifndef COMMON_FUNCTIONS_PV
#define COMMON_FUNCTIONS_PV
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <chrono>
#include <unistd.h>
#include <ctime>

unsigned long long int getTimeNS()
{
    return (std::chrono::duration_cast<std::chrono::nanoseconds>(std::chrono::system_clock::now().time_since_epoch())).count();
}
double getTimeSec()
{
    static unsigned long long int time0 = getTimeNS();
    return 1e-9 * double( getTimeNS() - time0);
}
static int printLog(const char* format, ...) 
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

#endif
