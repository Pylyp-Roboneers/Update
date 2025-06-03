#include <QApplication>
#include <string>
#include "dialog.h"
#include "common.h"
using namespace std;

int handleOfPostpone(int WaitTimeSec = 259200); // 259200 sec = 3 deys

int main(int argc, char *argv[])
{
    printLog("Start. Arguments number %d\n", argc);
    ServerComunicationData ServerData("ToUpdateFromServer.sh");
    ServerData.print();

    QApplication a(argc, argv);
    Dialog AutoDialog;
    Dialog2 UserDialog; 

    if(argc<=1)
    {
        if(handleOfPostpone(stoi(ServerData.AUTORUN_POSTPONE_TIME_SEC))) return 0;
        time_t now = time(0);
        tm* ltm = localtime(&now);   // current date and time for log file sufix

        char DateTime[25];  // string of log file sufix
        sprintf(DateTime, "%02d%02d%02d_%02d%02d%02d"
            , ltm->tm_year - 100, 1 + ltm->tm_mon, ltm->tm_mday
            , ltm->tm_hour, ltm->tm_min, ltm->tm_sec);
        string LogFileName = string("Log")+ string(DateTime) + string("_.txt");

        // command to copy update archive from Srver with log in file
        string Command = "";
        // Command += " konsole -e $SHELL -c \"";
        Command += "$(pwd)/ToUpdateFromServer.sh --ping";
        Command += string(" > $(pwd)/") + LogFileName; // print in log file
        // Command += "\"";
        int PingResult = system(Command.c_str());  // run copy command

        // if no copied update files from Server then close the dialog
        if(PingResult) 
        {
            system((string("sudo rm -f $(pwd)/") + LogFileName).c_str()); // delete empty log
            return 0;
        }
        else 
        {
            // send current log file to Server
            Command = string("sleep 3;") + ServerData.sshCopyToServerCommand( string("$(pwd)/") + LogFileName);
            printLog("\nLog copy: %s", Command.c_str());
            system(Command.c_str());
        }
        AutoDialog.show();
    }
    else
    {
        UserDialog.show();
    }

    return a.exec();
}

// Function handles postponed autorun of the program.
//  WaitTimeSec -  postponed time in seconds. 
// Start of posponed time is written in waitForPostponedUpdate.txt
int handleOfPostpone(int WaitTimeSec)  // WaitTimeSec: 1 day = 86400 sec
{
    FILE* Fpost = fopen("PostponedUpdateTime", "r");
    if(Fpost){
        unsigned long long int T = 0;
        fscanf(Fpost, "%lld", &T);
        fclose(Fpost);

        unsigned long long int dT = (Dialog::getTimeNS() -T) / 1e9;
        
        FILE* LogF = fopen("waitForPostponedUpdate.txt", "w");
        fprintf(LogF, "Read time %lld ns\ntime since postpone %lld sec\nleft %lld sec", T, dT, WaitTimeSec - dT);
        fclose(LogF);

        if(dT < WaitTimeSec) return 1;
        else
        {
            remove("PostponedUpdateTime");
            remove("waitForPostponedUpdate.txt");
        }
    }
    return 0;
}
