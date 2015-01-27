#include <iostream>
#include <sstream>
#include <cstdio>
#include <cmath>
#include <vector>
#include <fstream>
#include "ocr.h"
#include <QApplication>
#include <QString>

#include "matriz.h"

int N, M, K, M_X, M_Y;
vector<int> vectorImagen;
bool puedoProcesarBase = false;
bool baseDeDatosCargada = false;
bool datosCargados = false;
bool imagenCargada = false;
bool semaphore = true;
QString nombreDeLaImagen;

using namespace std;

extern void cargarLabel_asm (Matriz *label);
extern void cargarVt_asm (Matriz *V, Matriz *Vt, Matriz *A, bool baseDeDatosCargada);
extern void cargarTc_asm (Matriz *TC, bool baseDeDatosCargada, Matriz *A, Matriz *V, Matriz *label);
extern void cargarCaracter_asm (Matriz *X);
extern Matriz* matriz_create(const int row_count, const int column_count); //si
extern void matriz_delete(Matriz *self); //si
extern Matriz* matriz_multiplicar(Matriz *self, Matriz *b); // hace A * B y lo guarda en una matriz que crea llamada C si

int main(int argc, char **argv)
{
    /*------------------------------------------------------------------------------------------------------------
    en Vt.txt esta cargado Vt (puede no existir)
    en matriz.txt esta la base de datos (los digitos tienen que estar ordenados)
    en TC.txt esta tc (puede no existir)
    en label.txt estan las etiquetas (cantidad de imagenes de cada digito)
    -----------------------------------------------------------------------------------------------------------*/
    QApplication a(argc, argv);
    OCR m;
    m.show();

    return a.exec();
}
