#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QList>
#include <QMainWindow>
#include "ocr.h"

class ScribbleArea;
class OCR;

class MainWindow : public QMainWindow
{
    Q_OBJECT

public:
    MainWindow();

private slots:
    void save();

private:
    void createActions();
    void createMenus();

    ScribbleArea *scribbleArea;
    QAction *saveAct;
    QAction *exitAct;
    QAction *clearScreenAct;
};

#endif
