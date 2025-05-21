
#ifndef DIALOG_H
#define DIALOG_H
#include <stdio.h>
#include <stdlib.h>
#include <QDialog>
#include <QTimer>

QT_BEGIN_NAMESPACE
namespace Ui { class Dialog; }
QT_END_NAMESPACE

class Dialog : public QDialog
{
    Q_OBJECT

public:
    Dialog(QWidget *parent = nullptr);
    ~Dialog();
    QTimer LaterTimer;
    int Mode = 0;

private slots:
    void on_pushButton_clicked();
    void on_pushButton_2_clicked();
    void on_pushButton_3_clicked();
    void keyPressEvent(QKeyEvent *e);
    void LaterTimerHandler();
private:
    Ui::Dialog *ui;

    unsigned long long int getTimeNS()
    {
        return (std::chrono::duration_cast<std::chrono::nanoseconds>(std::chrono::system_clock::now().time_since_epoch())).count();
    }
    double getTimeSec()
    {
        static unsigned long long int time0 = getTimeNS();
        return 1e-9 * double( getTimeNS() - time0);
    }
};


#endif // DIALOG_H
