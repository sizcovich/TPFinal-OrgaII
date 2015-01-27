#include <QtWidgets>

#include "mainwindow.h"
#include "scribblearea.h"
#include "matriz.h"
#include "ocr.h"
#include <iostream>

using namespace std;

MainWindow::MainWindow()
{
    scribbleArea = new ScribbleArea;
    setCentralWidget(scribbleArea);
    createActions();
    createMenus();

    setWindowTitle(tr("Crear imagen"));
    resize(350, 350);
}

void MainWindow::save()
{
    const QByteArray &fileFormat = "JPG";
    const QString fileName = "/imagenes/imagen.jpg";
    scribbleArea->saveImage(fileName, fileFormat.constData());
    nombreDeLaImagen = QDir::currentPath() + "/imagenes/imagen.jpg";
    imagenCargada = true;
}

void MainWindow::createActions()
{

    saveAct = new QAction(tr("&Guardar"), this);
    connect(saveAct, SIGNAL(triggered()), SLOT(save()));
    connect(saveAct, SIGNAL(triggered()), this, SLOT(close()));

    exitAct = new QAction(tr("&Salir"), this);
    exitAct->setShortcuts(QKeySequence::Quit);
    connect(exitAct, SIGNAL(triggered()), this, SLOT(close()));

    clearScreenAct = new QAction(tr("&Limpiar Pantalla"), this);
    clearScreenAct->setShortcut(tr("Ctrl+L"));
    connect(clearScreenAct, SIGNAL(triggered()),
            scribbleArea, SLOT(clearImage()));
}

void MainWindow::createMenus()
{
    menuBar()->addAction(saveAct);
    menuBar()->addAction(clearScreenAct);
    menuBar()->addAction(exitAct);
}
