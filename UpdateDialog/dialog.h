
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

private slots:
    void on_pushButton_clicked();
    void on_pushButton_2_clicked();
    void on_pushButton_3_clicked();
    void keyPressEvent(QKeyEvent *e);
    void LaterTimerHandler();
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
private:
    Ui::Dialog2 *ui;
private slots:
    void on_pushButton_clicked();    // handle of "Update" button
    void on_pushButton_2_clicked();  // handle of "Back Up" button
    void on_pushButton_3_clicked();
    void on_pushButton_4_clicked();  // handle of "Cancel" button
};
#endif // DIALOG_H
