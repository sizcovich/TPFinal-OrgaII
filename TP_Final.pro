#-------------------------------------------------
#
# Project created by QtCreator 2014-04-06T15:45:59
#
#-------------------------------------------------

QT       += core gui
qtHaveModule(printsupport): QT += printsupport

greaterThan(QT_MAJOR_VERSION, 4): QT += widgets

TARGET = TP_Final
TEMPLATE = app


SOURCES += codigo/main.cpp\
        codigo/ocr.cpp \
    codigo/matriz_c.cpp \
    codigo/funciones_asm.cpp \
    codigo/matriz_asm.asm \
    codigo/scribblearea.cpp \
    codigo/mainwindow.cpp

HEADERS  += codigo/ocr.h \
    codigo/matriz.h \
    codigo/scribblearea.h \
    codigo/mainwindow.h

FORMS    += codigo/ocr.ui

OTHER_FILES += \
    codigo/matriz_asm.asm
