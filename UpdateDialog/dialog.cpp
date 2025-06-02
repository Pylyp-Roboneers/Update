#include <fstream>
#include <string>
#include "dialog.h"
#include "./ui_dialog.h"
#include "./ui_dialog2.h"
#include "QDebug"
#include <QKeyEvent>

Dialog::Dialog(QWidget *parent): QDialog(parent), ui(new Ui::Dialog)
{
    ui->setupUi(this);
    ServerData.update("ToUpdateFromServer.sh");
}

Dialog::~Dialog()
{
    delete ui;
}

// Handle of "update" button
void Dialog::on_pushButton_clicked()
{
    system(ServerData.BashCommandWithLog("--replace").c_str());
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
    // save current time to postpone autorun
    FILE* F = fopen("PostponedUpdateTime", "w");
    fprintf(F, "%lld", getTimeNS());
    fclose(F);
   
    QDialog::done(0);  // close dialog
}

// Handler of key hit
void Dialog::keyPressEvent(QKeyEvent *e)
{
    // Procedure copies saved previously backup files to
    // correspondent folders by pressing Alt-r
    if(e->type() == QEvent::KeyPress)
    if(e->modifiers().testFlag(Qt::AltModifier) && (char)(e->key())== Qt::Key_R)
    {
        system(ServerData.BashCommandWithLog("--restore").c_str());
    }

    QDialog::keyPressEvent(e);
}

Dialog2::Dialog2(QWidget *parent): QDialog(parent), ui(new Ui::Dialog2)
{
    ui->setupUi(this);
    ServerData.update("ToUpdateFromServer.sh");
}
Dialog2::~Dialog2()
{
    delete ui;
}

// handle of "Update" button
void Dialog2::on_pushButton_clicked()
{
    printLog("\nDialog2 Update");
    printLog("\non_pushButton_clicked: %s", ServerData.BashCommandWithLog("--full").c_str());
    system(ServerData.BashCommandWithLog("--full").c_str());
}
// handle of "Back Up" button
void Dialog2::on_pushButton_2_clicked()
{
    printLog("\nDialog2 Back Up");
    printLog("\non_pushButton_clicked: %s", ServerData.BashCommandWithLog("--full").c_str());
    system(ServerData.BashCommandWithLog("--restore").c_str());
}
// handle of "Extract" button
void Dialog2::on_pushButton_3_clicked()
{
    printLog("\nDialog2 Extract %d %5.3f",2, 4.7);
    printLog("\non_pushButton_clicked: %s", ServerData.BashCommandWithLog("--extract").c_str());
    system(ServerData.BashCommandWithLog("--extract").c_str());
}
// handle of "Cancel" button
void Dialog2::on_pushButton_4_clicked()
{
    printLog("\nd2 Cancel");
    QDialog::done(0);  // close dialog
}
