
#include "dialog.h"
#include <QApplication>

int main(int argc, char *argv[])
{
    // check connection to Server
    int PingResult = system("$(pwd)/ToUpdateFromServer.sh --ping > $(pwd)/ping.txt");
    // FILE* LogF = fopen("pingLog.txt", "w");
    // fprintf(LogF, "The result of ping: %d", PingResult);
    // fclose(LogF);
    if(PingResult) return 0;

    QApplication a(argc, argv);
    Dialog w;
    w.show();
    return a.exec();
}
