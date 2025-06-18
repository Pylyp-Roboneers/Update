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
void Dialog::resizeEvent(QResizeEvent *event)
{    
    float ResX = 1280., ResY = 800.;
    int indent = 40;
    auto DlgSize = this->size();
    float Sx = DlgSize.width() / ResX;  // Scale X
    float Sy = DlgSize.height() / ResY;  // Scale Y

    // Update button
    ui->pushButton->setGeometry((ResX- 551) * Sx /2, DlgSize.height() * 4.5/8., 551 * Sx, 100 * Sy);
    QFont font = ui->pushButton->font();
    font.setPointSize(21 * Sx);
    ui->pushButton->setFont(font);
    QPalette pal=palette();
    pal.setBrush(QPalette::Button, Qt::white);  // background color
    pal.setBrush(QPalette::ButtonText, Qt::black);  // text color
    ui->pushButton->setPalette(pal);

    // Later button
    ui->pushButton_3->setGeometry(indent * Sx, DlgSize.height() - (indent + 100) * Sy
        , (ResX - 3 * indent) * Sx /2, 100 * Sy);
    ui->pushButton_3->setFont(font);

    // Cancel button
    ui->pushButton_2->setGeometry((ResX + indent) * Sx / 2, DlgSize.height() -  (indent + 100) * Sy
        , (ResX - 3 * indent) * Sx /2, 100 * Sy);
    ui->pushButton_2->setFont(font);

    // Comment text
    ui->textComment->setGeometry((ResX - 800) * Sx /2, DlgSize.height() * 2.75 /8., 800 * Sx, 100 * Sy);
    ui->textComment->setStyleSheet("color: white; background-color: transparent;");
    ui->textComment->setAlignment(Qt::AlignCenter);
    QFont fontTCom = ui->textComment->font();
    fontTCom.setPointSize(30 * Sx);
    ui->textComment->setFont(fontTCom);

    ui->companyLogo->setGeometry(32 * Sx, 32 * Sy, 32 * Sx, 32 * Sy);
    ui->companyName->setGeometry(72 * Sx, 38 * Sy, 182 * Sx, 20 * Sy);

    QDialog::resizeEvent(event);
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
    printLog("\non_pushButton_clicked: %s", ServerData.BashCommandWithLog("--force").c_str());
    system(ServerData.BashCommandWithLog("--force").c_str());
}
// handle of "Back Up" button
void Dialog2::on_pushButton_2_clicked()
{
    printLog("\nDialog2 Back Up");
    printLog("\non_pushButton_clicked: %s", ServerData.BashCommandWithLog("--restore").c_str());
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
void Dialog2::resizeEvent(QResizeEvent *event)
{    
    float ResX = 1280., ResY = 800.;
    int indent = 40;
    auto DlgSize = this->size();
    float Sx = DlgSize.width() / ResX;  // Scale X
    float Sy = DlgSize.height() / ResY;  // Scale Y

    // Restore button
    ui->pushButton_2->setGeometry((ResX - 750) * Sx /2, DlgSize.height() * 4.5 / 8., 750 * Sx, 100 * Sy);
    QFont font = ui->pushButton_2->font();
    font.setPointSize(21 * Sx);
    ui->pushButton_2->setFont(font);
    QPalette pal=palette();
    pal.setBrush(QPalette::Button, QColor( 255, 255, 255));  // background color
    pal.setBrush(QPalette::ButtonText, Qt::black);  // text color
    ui->pushButton_2->setPalette(pal);

    // // Update button
    // ui->pushButton->setGeometry( (DlgSize.width() + indent * Sx) / 2, indent * Sy
    //     , (ResX - 3 * indent) * Sx /2, 100 * Sy);
    // ui->pushButton->setFont(font);

    // Extract button
    ui->pushButton_3->setGeometry(indent * Sx, DlgSize.height() - (indent + 100) * Sy
        , (ResX - 3 * indent) * Sx /2, 100 * Sy);
    ui->pushButton_3->setFont(font);

    // Cancel button
    ui->pushButton_4->setGeometry((ResX + indent) * Sx / 2, DlgSize.height() -  (indent + 100) * Sy
        , (ResX - 3 * indent) * Sx /2, 100 * Sy);
    ui->pushButton_4->setFont(font);

    ui->companyLogo->setGeometry(32 * Sx, 32 * Sy, 32 * Sx, 32 * Sy);
    ui->companyName->setGeometry(72 * Sx, 38 * Sy, 182 * Sx, 20 * Sy);

    QDialog::resizeEvent(event);
}
