#ifndef _MATRIZ_H_
#define _MATRIZ_H_

using namespace std;
#include <string>
#include <vector>
#include <QString>
#ifdef __cplusplus
extern "C" {
#endif

class QString;

extern int N; // cantidad de imagenes
extern int M; // tamaño de imagen
extern int K;
extern int M_X;
extern int M_Y;
extern vector<int> vectorImagen;
extern bool imagenCargada;
extern bool semaphore;

extern QString nombreDeLaImagen;

extern bool puedoProcesarBase, baseDeDatosCargada, datosCargados;

    typedef struct Matriz {
        int fila;
        int columna;
        float* Vector;
    } __attribute__((__packed__)) Matriz;
    
    
    /*
     Matriz tiene fila = 2, columna = 3, vector apuntando a celdaA
     
     --- --- ---
     | A | B | C |              --- --- --- --- --- ---
     --- --- ---       =>     | A | B | C | D | E | F |
     | D | E | F |              --- --- --- --- --- ---
     --- --- ---
     */

    void cargarLabel (Matriz *label);
    void cargarVt (Matriz *V, Matriz *Vt, Matriz *A, bool *baseDeDatosCargada);
    void cargarTc (Matriz *TC, bool baseDeDatosCargada, Matriz *A, Matriz *V);
    void cargarCaracter (Matriz *X);
    
    Matriz* Create(const int row_count, const int column_count);
    void Delete(Matriz *self);
    
    void cero(Matriz *self); // pone en 0 a toda la matriz
    void identidad(Matriz *self);
    Matriz* multiplicar(Matriz *self, Matriz *b); // hace A * B y lo guarda en una matriz que crea llamada C
    void dividir(Matriz *self, const float v);
    void copiar(Matriz *self, Matriz *b); // copia una matriz toma b y lo copia a self
    void traspuesta(Matriz *self, Matriz *res); // para matrices no cuadradas
    void traspuestaCuadrada(Matriz *self); // para matrices cuadradas
    void mediaCero(Matriz *self); // hace xi-mu
    double norma2(Matriz *self);
    void rotacion(Matriz *self, Matriz *Q, int i, int j);
    void multiplicarThis(Matriz *self, Matriz *b); // hace A * B y lo guarda en A
    void multiplicarParametro(Matriz *self, Matriz *b); // hace A * B y lo guarda en B
    void set(Matriz *self, const int row, const int col, float valor);
    float get(Matriz *self, const int row, const int col);
    int cantidadFilas(Matriz *self);
    int cantidadColumnas(Matriz *self);
    int averiguarDigito(Matriz *self, Matriz *tcX, Matriz *label);
    void factorizacionQR (Matriz *self, Matriz *Q, float toleranciaNumero);
    void algoritmoQR(Matriz *self, Matriz *res,float toleranciaSumaSuperior, float toleranciaNumero);
    bool paradaQR(Matriz *self, float tol);
    Matriz* calcularPromedioTC(Matriz *self, Matriz* label);
    

    //funciones assembler
    void cargarLabel_asm (Matriz *label);
    void cargarVt_asm (Matriz *V, Matriz *Vt, Matriz *A, bool *baseDeDatosCargada);
    void cargarTc_asm (Matriz *TC, bool baseDeDatosCargada, Matriz *A, Matriz *V);
    void cargarCaracter_asm (Matriz *X);

    Matriz* matriz_create(const int row_count, const int column_count);
    void matriz_delete(Matriz *self);
    
    void matriz_cero(Matriz *self); // pone en 0 a toda la matriz
    void matriz_identidad(Matriz *self);
    Matriz* matriz_multiplicar(Matriz *self, Matriz *b); // hace A * B y lo guarda en una matriz que crea llamada C
    void matriz_dividir(Matriz *self, const float v);
    void matriz_copiar(Matriz *self, Matriz *b); // copia una matriz toma b y lo copia a self
    void matriz_traspuesta(Matriz *self, Matriz *res); // para matrices no cuadradas
    void matriz_traspuestaCuadrada(Matriz *self); // para matrices cuadradas
    void matriz_mediaCero(Matriz *self); // hace xi-mu
    void matriz_print(Matriz* self, char* archivo);
    double matriz_norma2(Matriz *self);
    void matriz_cargar(Matriz* self, int i, int j, double valor);
    void matriz_rotacion(Matriz *self, Matriz *Q, int i, int j);

    void multiplicarThis_asm(Matriz *self, Matriz *b); // hace A * B y lo guarda en A
    void multiplicarParametro_asm(Matriz *self, Matriz *b); // hace A * B y lo guarda en B
    int averiguarDigito_asm(Matriz *self, Matriz *tcX, Matriz *label);
    void factorizacionQR_asm(Matriz *self, Matriz *Q, float toleranciaNumero);
    void algoritmoQR_asm(Matriz *self, Matriz *res,float toleranciaSumaSuperior, float toleranciaNumero);
    bool paradaQR_asm(Matriz *self, float tol);
    Matriz* calcularPromedioTC_asm(Matriz *self, Matriz* label);
    
#ifdef __cplusplus
}
#endif

#endif // _MATRIZ_H_
