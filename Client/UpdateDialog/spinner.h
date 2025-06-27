#ifndef SPINNER_H
#define SPINNER_H
#include <QDialog>
#include <QVBoxLayout>
#include <QLabel>
#include <QMovie>
using namespace std;
class Spinner : public QWidget
{
Q_OBJECT
QVBoxLayout *layout;
QLabel *spinnerLabel;
QMovie *movie;
public:
   Spinner(QWidget *parent) : QWidget(parent)
    {
        layout = new QVBoxLayout(parent);
        spinnerLabel = new QLabel(parent);
        movie = new QMovie(":/prgrss/spinner.gif");
        spinnerLabel->setMovie(movie);
        layout->addWidget(spinnerLabel, 0, Qt::AlignCenter);
        movie->stop();
        spinnerLabel->move(0,0);
        setLayout(layout);
        // spinnerLabel->setGeometry(0, 0, 200, 200);

        setAttribute(Qt::WA_StyledBackground);
        setStyleSheet("background-color: rgba( 255, 255, 255, 0% )");
        hide();
        setWindowModality(Qt::ApplicationModal);
    }
    ~Spinner(){delete movie; delete spinnerLabel; delete layout;}
    void start() 
    {
        if (parentWidget()) 
        {
            // resize(parentWidget()->size());
            // move(parentWidget()->pos());
            // printLog("\nparentWidget %d  %d", parentWidget()->size().width(), parentWidget()->size().height());
            // qDebug()<< "parentWidget()->size() " <<parentWidget()->size();
            // qDebug()<< "parentWidget()->pos() " <<parentWidget()->pos();
            parentWidget()->setEnabled(false);
            movie->start();
            show();
        }
    }
    void stop()
    {
        if(parentWidget())
        {
            parentWidget()->setEnabled(true);
            movie->stop();
            hide();
        }
    }
};
#endif // SPINNER_H
