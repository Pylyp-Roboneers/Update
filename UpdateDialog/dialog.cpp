#include "dialog.h"
#include "./ui_dialog.h"
#include "./ui_dialog2.h"
#include "QDebug"
#include <QKeyEvent>
#include "common.h"

Dialog::Dialog(QWidget *parent): QDialog(parent), ui(new Ui::Dialog)
{
    ui->setupUi(this);
    connect(&LaterTimer, SIGNAL(timeout()), this, SLOT(LaterTimerHandler()));
}

Dialog::~Dialog()
{
    delete ui;
}

// Handle of "update" button
void Dialog::on_pushButton_clicked()
{
    system("LogFileName=$(pwd)/Log$(date +\"%y%m%d_%H%M\%S\").txt;"
        " konsole -e $SHELL -c \"$(pwd)/ToUpdateFromServer.sh --replace | tee $LogFileName; sleep 5;\""
        " sleep 3; konsole -e $SHELL -c \" scp -i /home/deck/.ssh/keyToServer -P 2222 $LogFileName pi@77.222.152.213:theWD/LOGS/\"");
        // " sleep 3; konsole -e $SHELL -c \"cp $LogFileName /home/deck/Downloads/1\"");

    // system("konsole -e $SHELL -c \"$(pwd)/ToUpdateFromServer.sh | tee $(pwd)/Log$(date +\"%y%m_%H%M\%S\").txt\"");
    // system("konsole -e $(pwd)/ToUpdateFromServer.sh");
    QDialog::done(0);
}

// Handle of "cancel" button
void Dialog::on_pushButton_2_clicked()
{
    QDialog::done(0);
}

// Handler of "Later" button
void Dialog::on_pushButton_3_clicked()
{
    FILE* F = fopen("PostponedUpdateTime", "w");
    fprintf(F, "%lld", getTimeNS());
    fclose(F);
    
    // close dialog
    QDialog::done(0);
}

// Handler of key hit
void Dialog::keyPressEvent(QKeyEvent *e)
{
    // Procedure copies saved previously backup files to
    // correspondent folders by pressing Alt-r
    if(e->type() == QEvent::KeyPress)
    if(e->modifiers().testFlag(Qt::AltModifier) && (char)(e->key())== Qt::Key_R)
    {
        system("LogFileName=$(pwd)/Log$(date +\"%y%m%d_%H%M\%S\").txt;"
            " konsole -e $SHELL -c \"$(pwd)/ToUpdateFromServer.sh --backup | tee $LogFileName;\""
            " sleep 3; konsole -e $SHELL -c \" scp -i /home/deck/.ssh/keyToServer -P 2222 $LogFileName pi@77.222.152.213:theWD/LOGS/\"");
    }

    QDialog::keyPressEvent(e);
}

// Timer handler to proceed dialog later on defined time 
void Dialog::LaterTimerHandler()
{
    this->showNormal();
    LaterTimer.stop();
}


Dialog2::Dialog2(QWidget *parent): QDialog(parent), ui(new Ui::Dialog2)
{
    ui->setupUi(this);
}
Dialog2::~Dialog2()
{
    delete ui;
}
// handle of "Update" button
void Dialog2::on_pushButton_clicked()
{
    printLog("\nd2 Update %d %5.3f",2, 4.7);
    system("LogFileName=$(pwd)/Log$(date +\"%y%m%d_%H%M\%S\").txt;"
        " konsole -e $SHELL -c \"$(pwd)/ToUpdateFromServer.sh | tee $LogFileName;\""
        " sleep 3; konsole -e $SHELL -c \" scp -i /home/deck/.ssh/keyToServer -P 2222 $LogFileName pi@77.222.152.213:theWD/LOGS/\"");
}
// handle of "Back Up" button
void Dialog2::on_pushButton_2_clicked()
{
    printLog("\nd2 Back Up");
    system("LogFileName=$(pwd)/Log$(date +\"%y%m%d_%H%M\%S\").txt;"
        " konsole -e $SHELL -c \"$(pwd)/ToUpdateFromServer.sh --backup | tee $LogFileName;\""
        " sleep 3; konsole -e $SHELL -c \" scp -i /home/deck/.ssh/keyToServer -P 2222 $LogFileName pi@77.222.152.213:theWD/LOGS/\"");
}
void Dialog2::on_pushButton_3_clicked()
{
    printLog("\nd2 Extract");
}
// handle of "Cancel" button
void Dialog2::on_pushButton_4_clicked()
{
    printLog("\nd2 Cansel");
    QDialog::done(0);  // close dialog
}
