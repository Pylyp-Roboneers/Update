#include <QApplication>
#include <string>
#include "dialog.h"
using namespace std;

int main(int argc, char *argv[])
{
    if(argc<=1)
    {
        time_t now = time(0);
        tm* ltm = localtime(&now);   // current date and time for log file sufix

        char DateTime[25];  // string of log file sufix
        sprintf(DateTime, "%02d%02d%02d_%02d%02d%02d"
            , ltm->tm_year - 100, 1 + ltm->tm_mon, ltm->tm_mday
            , ltm->tm_hour, ltm->tm_min, ltm->tm_sec);
        string LogFileName = string("Log")+ string(DateTime) + string("copy.txt");

        // command to copy update archive from Srver with log in file
        string Command = "$(pwd)/ToUpdateFromServer.sh --ping";
        Command += string(" > $(pwd)/") + LogFileName; // print in log file
        int PingResult = system(Command.c_str());  // run copy command

        // if no copied update files from Server then close the dialog
        if(PingResult && argc <= 1) 
        {
            system((string("sudo rm -f $(pwd)/") + LogFileName).c_str());
            // FILE* LogF = fopen("pingLog.txt", "w");
            // fprintf(LogF, "The result of ping: %d", PingResult);
            // fclose(LogF);
            return 0;
        }

        // send curremt log file to Server
        Command = string("sleep 3; scp -i /home/deck/.ssh/keyToServer -P 2222 " )
            + string("$(pwd)/") + LogFileName
            + string(" pi@77.222.152.213:theWD/LOGS/");
        system(Command.c_str());
    }
    // Run dialog
    QApplication a(argc, argv);
    Dialog w;
    w.Mode = (argc>1)?1:0;
    w.show();
    return a.exec();
}
