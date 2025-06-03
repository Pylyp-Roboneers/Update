#ifndef DIALOG_H
#define DIALOG_H
#include <stdio.h>
#include <stdlib.h>
#include <QDialog>
#include <QTimer>
#include <string>
#include "common.h"
using namespace std;

struct ServerComunicationData
{
    string BashFileName = "NONE";
    string SERVER_USER = "None";
    string SERVER_ADRESS = "None";
    string SERVER_PORT = "None";
    string SERVER_FOLER = "None";
    string LOCAL_SSHkeyToServer = "None";
    string AUTORUN_POSTPONE_TIME_SEC =  "259200";
    ServerComunicationData(){}
    ServerComunicationData(const char* ShFileName)
    {
        if(ShFileName) update(ShFileName); 
    }
    void update(const char* ShFileName)
    {
        BashFileName = ShFileName;
        SERVER_USER = findInFile(ShFileName, "SERVER_USER=");
        SERVER_ADRESS = findInFile(ShFileName, "SERVER_ADRESS=");
        SERVER_PORT = findInFile(ShFileName, "SERVER_PORT=");
        if(SERVER_PORT!="") SERVER_PORT = " -P " + SERVER_PORT;
        SERVER_FOLER = findInFile(ShFileName, "SERVER_FOLER=");
        LOCAL_SSHkeyToServer = findInFile(ShFileName, "LOCAL_SSHkeyToServer=");
            if (LOCAL_SSHkeyToServer!="") LOCAL_SSHkeyToServer=string(" -i ") + LOCAL_SSHkeyToServer;
        AUTORUN_POSTPONE_TIME_SEC = findInFile(ShFileName, "AUTORUN_POSTPONE_TIME_SEC=");
    }
    string sshCopyToServerCommand(string source)
    {
         //scp -i /home/deck/.ssh/keyToServer -P 2222 $LogFileName pi@77.222.152.213:theWD/LOGS/
        string Command = string(" scp ") + LOCAL_SSHkeyToServer + SERVER_PORT  + " ";
        Command += source + " " + SERVER_USER + "@" + SERVER_ADRESS 
            + string(":") + SERVER_FOLER + "/LOGS";
        return Command;
    }
    string BashCommandWithLog(const char* argument)
    {
        string Command = "LogFileName=$(pwd)/Log$(date +\"%y%m%d_%H%M\%S\").txt;";
        Command += " konsole -e $SHELL -c \"$(pwd)/";
        Command += BashFileName + " " + string(argument) + " | tee $LogFileName; sleep 10;\"";
        Command += "\n sleep 3; \n konsole -e $SHELL -c \" scp ";
        Command += LOCAL_SSHkeyToServer + SERVER_PORT;
        Command += " $LogFileName " + SERVER_USER + "@" + SERVER_ADRESS + ":";
        Command += SERVER_FOLER + "/LOGS/\"";
        return Command;
        // "LogFileName=$(pwd)/Log$(date +\"%y%m%d_%H%M\%S\").txt;"
        // " konsole -e $SHELL -c \"$(pwd)/ToUpdateFromServer.sh --extract | tee $LogFileName; sleep 10\""
        // " konsole -e $SHELL -c \" scp -i /home/deck/.ssh/keyToServer -P 2222 $LogFileName pi@77.222.152.213:theWD/LOGS/\""
    }
    void print()
    {
        printLog("Patrameters of communication with Server");
        printLog("\nSERVER_USER:\t%s", SERVER_USER.c_str());
        printLog("\nSERVER_ADRESS:\t%s", SERVER_ADRESS.c_str());
        printLog("\nSERVER_PORT:\t%s", SERVER_PORT.c_str());
        printLog("\nSERVER_FOLER:\t%s", SERVER_FOLER.c_str());
        printLog("\nLOCAL_SSHkeyToServer:\t%s", LOCAL_SSHkeyToServer.c_str());
        printLog("\nAUTORUN_POSTPONE_TIME_SEC:\t%s (%d sec)"
            , AUTORUN_POSTPONE_TIME_SEC.c_str(), stoi(AUTORUN_POSTPONE_TIME_SEC));
        printLog("\n%s", sshCopyToServerCommand("Source").c_str());
    }
};

QT_BEGIN_NAMESPACE
namespace Ui { class Dialog; }
QT_END_NAMESPACE

class Dialog : public QDialog
{
    Q_OBJECT
public:
    Dialog(QWidget *parent = nullptr);
    ~Dialog();
    ServerComunicationData ServerData;
    QTimer LaterTimer;

private slots:
    void on_pushButton_clicked();
    void on_pushButton_2_clicked();
    void on_pushButton_3_clicked();
    void keyPressEvent(QKeyEvent *e);
private:
    Ui::Dialog *ui;

public:
    static unsigned long long int getTimeNS()
    {
        return (std::chrono::duration_cast<std::chrono::nanoseconds>(std::chrono::system_clock::now().time_since_epoch())).count();
    }
    static double getTimeSec()
    {
        static unsigned long long int time0 = getTimeNS();
        return 1e-9 * double( getTimeNS() - time0);
    }
};

namespace Ui {class Dialog2;}
class Dialog2 : public QDialog
{
    Q_OBJECT
public:
    explicit Dialog2(QWidget *parent = nullptr);
    ~Dialog2();
    ServerComunicationData ServerData;
private:
    Ui::Dialog2 *ui;
private slots:
    void on_pushButton_clicked();    // handle of "Update" button
    void on_pushButton_2_clicked();  // handle of "Back Up" button
    void on_pushButton_3_clicked();
    void on_pushButton_4_clicked();  // handle of "Cancel" button
};
#endif // DIALOG_H
