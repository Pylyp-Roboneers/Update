#include <QApplication>
#include <string>
#include "dialog.h"
#include "common.h"
using namespace std;

int handleOfPostpone(int WaitTime = 30);

int main(int argc, char *argv[])
{
    printLog("\nStart");
    printLog("\nSERVER_USER:\t%s", findInFile("ToUpdateFromServer.sh", "SERVER_USER=").c_str());
    printLog("\nSERVER_ADRESS:\t%s", findInFile("ToUpdateFromServer.sh", "SERVER_ADRESS=").c_str());
    printLog("\nSERVER_PORT:\t%s", findInFile("ToUpdateFromServer.sh", "SERVER_PORT=").c_str());
    printLog("\nSERVER_FOLER:\t%s", findInFile("ToUpdateFromServer.sh", "SERVER_FOLER=").c_str());
    printLog("\nLOCAL_SSHkeyToServer:\t%s", findInFile("ToUpdateFromServer.sh", "LOCAL_SSHkeyToServer=").c_str());

    QApplication a(argc, argv);
    Dialog AutoDialog;
    Dialog2 w2; 

    if(argc<=1)
    {
        // if(handleOfPostpone()) return 0;
        time_t now = time(0);
        tm* ltm = localtime(&now);   // current date and time for log file sufix

        char DateTime[25];  // string of log file sufix
        sprintf(DateTime, "%02d%02d%02d_%02d%02d%02d"
            , ltm->tm_year - 100, 1 + ltm->tm_mon, ltm->tm_mday
            , ltm->tm_hour, ltm->tm_min, ltm->tm_sec);
        string LogFileName = string("Log")+ string(DateTime) + string("_.txt");

        printLog("Start at %s\n", DateTime);

        // command to copy update archive from Srver with log in file
        string Command = "$(pwd)/ToUpdateFromServer.sh --ping";
        Command += string(" > $(pwd)/") + LogFileName; // print in log file
        int PingResult = system(Command.c_str());  // run copy command

        // if no copied update files from Server then close the dialog
        if(PingResult) 
        {
            system((string("sudo rm -f $(pwd)/") + LogFileName).c_str()); // delete empty log
            return 0;
        }
        else 
        {
            // send curremt log file to Server
            Command = string("sleep 3; scp -i /home/deck/.ssh/keyToServer -P 2222 " )
                + string("$(pwd)/") + LogFileName
                + string(" pi@77.222.152.213:theWD/LOGS/");
            system(Command.c_str());
        }
    AutoDialog.show();
    }
    else
    {
        w2.show();
    }
        // if(argc>1) {Dialog2 w2; w2.show();}

    return a.exec();
}

int handleOfPostpone(int WaitTime)
{
    FILE* Fpost = fopen("PostponedUpdateTime", "r");
    if(Fpost){
        unsigned long long int T = 0;
        fscanf(Fpost, "%lld", &T);
        fclose(Fpost);

        unsigned long long int dT = (Dialog::getTimeNS() -T) / 1e9;
        
        FILE* LogF = fopen("waitForPostponedUpdate.txt", "w");
        fprintf(LogF, "Read time %lld ns\ntime since postpone %lld sec\nleft %lld sec", T, dT, WaitTime - dT);
        fclose(LogF);

        if(dT < WaitTime) return 1;
        else
        {
            remove("PostponedUpdateTime");
            remove("waitForPostponedUpdate.txt");
        }
    }
    return 0;
}
