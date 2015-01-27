#ifndef OCR_H
#define OCR_H

#include <QWidget>
#include <QPushButton>
#include <QTextEdit>
#include <QLabel>
#include <QProgressBar>
#include <QString>
#include <QImage>
#include <QApplication>
#include <QFileDialog>
#include <QRgb>
#include <QDialog>

#include "mainwindow.h"

class QPushButton;
class QWidget;
class QTextEdit;
class QLabel;
class QProgressBar;
class QString;
class QImage;
class QApplication;
class QFileDialog;
class QDialog;
class MainWindow;

namespace Ui {
class OCR;
}

class OCR : public QWidget
{
    Q_OBJECT

public:
    OCR(QWidget *parent = 0);
    ~OCR();
    QImage mostrarImagen;

private:
    Ui::OCR *ui;
    MainWindow *mw;

private slots:
     void on_BotonEmpezar_clicked();
     void on_cargarBase_clicked();
     void on_Aceptar_clicked();
     void on_Cancelar_clicked();
     void on_otroDigito_clicked();
     void on_averiguarDigito_clicked();
     void on_CargarImagen_clicked();
     void on_crearImagen_clicked();


private:
     QWidget *Bienvenida;
     QWidget *Principal;
     QWidget *CargarBase;
     QWidget *Resultado;
     QWidget *Cargando;
};

#endif // OCR_H
