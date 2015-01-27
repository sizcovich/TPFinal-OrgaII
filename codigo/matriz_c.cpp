#include <iostream>
#include <cmath>
#include <limits>
#include <fstream>
#include <vector>
#include <string>
#include "matriz.h"

using namespace std;

void cargarLabel (Matriz *label) { 
    ifstream archivoLabel;
    archivoLabel.open("archivos/label.txt");
    if(archivoLabel.good() && archivoLabel.is_open())
    {
        cout << "Cargando etiquetas" << endl;
        float elem;
        for(int i = 0; i < N; i++)
        {
            archivoLabel >> elem;
            set(label,0,i,elem);
        }
        cout << "etiquetas cargadas" << endl << endl;
    }
    else
    {
        cout << "No existe la etiqueta. El programa no puede continuar." <<  endl;
        int aux;
        cin >> aux;
    }
    archivoLabel.close();
}

void cargarVt (Matriz *V, Matriz *Vt, Matriz *A, bool *baseDeDatosCargada) {
    ifstream archivoVt;
    archivoVt.open("archivos/Vt.txt");
    if(archivoVt.good() && archivoVt.is_open())
    {
        cout << "Cargando Vt desde archivo" << endl;
        float aux;
        for (int i = 0; i < M; i++)
        {
            for(int j = 0; j < M; j++)
            {
                archivoVt >> aux;
                set(V,i,j,aux);
                if (i < K)
                    set(Vt,i,j,aux);
            }
        }
        cout << "Matriz Vt cargada" << endl << endl;

        ofstream escribirDatos;
        escribirDatos.open ("archivos/Datos.txt", ofstream::trunc);
        if(escribirDatos.good() && escribirDatos.is_open())
        {
            escribirDatos << N << " " << M << " " << K << " " << M_X << " " << M_Y;
        }
        escribirDatos.close();
    }
    else //genero vt
    {
        cout << "Creando Vt" << endl;
        ifstream entradaDB;
        entradaDB.open("archivos/matriz.txt");
        if(entradaDB.good() && entradaDB.is_open())
        {
            cout << "Cargando la base de datos" << endl;

            Matriz *base = Create(N,M); 
            float aux;
            
            for (int i = 0; i < N; i++)
            {
                for(int j = 0; j < M; j++)
                {
                    entradaDB >> aux;
                    if (aux < 50) aux = 0; else aux = 255;
                    set(A,i,j,aux);
                    set(base,i,j,aux);
                }
            }
            
            *baseDeDatosCargada = true;
            cout << "Base de datos cargada" << endl;
            mediaCero(base);
            
            Matriz *Xt = Create(cantidadColumnas(base), cantidadFilas(base));
            traspuesta(base, Xt);
            Matriz *E = NULL;//Create(cantidadColumnas(base), cantidadColumnas(base));
            
            E = multiplicar(Xt, base); 
            dividir(E, N-1);
            Delete(base);
            Delete(Xt);
        
            cout << "Creada Xt * X" << endl;
            
            /*Algoritmo QR*/
            float toleranciaSumaSuperior = 20000; //fija una tolerancia para los elementos que estan en la parte de abajo de la diagonal de R.
            float toleranciaNumero = 0.00001;

            algoritmoQR(E,V,toleranciaSumaSuperior, toleranciaNumero); 
            Delete(E);
            
            traspuestaCuadrada(V);
            // en V me quedaron los autovectores de Xt * X como filas

            // guardo V
            ofstream escribirVt;
            escribirVt.open ("archivos/Vt.txt", ofstream::trunc);
            if(escribirVt.good() && escribirVt.is_open())
            {
                for(int i = 0; i < M; i++)
                {
                    for(int j = 0; j < M; j++)
                    {
                        escribirVt << get(V,i,j) << " ";
                        if (i < K)
                        {
                            set(Vt,i,j, (get(V,i,j)));
                        }
                    }
                    escribirVt << endl;
                }
            }
            escribirVt.close();

            ofstream escribirDatos;
            escribirDatos.open ("archivos/Datos.txt", ofstream::trunc);
            if(escribirDatos.good() && escribirDatos.is_open())
            {
                escribirDatos << N << " " << M << " " << K << " " << M_X << " " << M_Y;
            }
            escribirDatos.close();
            cout << "Creada y guardada Vt" << endl << endl;
        }
        else
        {
            cout << "No existe el archivo de la base de datos." << endl << "El programa no puede continuar" << endl;
            int aux;
            cin >> aux;
        }
        entradaDB.close();
    }
    archivoVt.close();
}

void cargarTc (Matriz *TC, bool baseDeDatosCargada, Matriz *A, Matriz *V) {
    ifstream archivoTC;
    archivoTC.open("archivos/TC_C.txt");
    if(archivoTC.good() && archivoTC.is_open())
    {
        cout << "Cargando la matriz TC" << endl;
        float aux;
        for (int i = 0; i < K; i++)
        {
            for(int j = 0; j < N; j++)
            {
                archivoTC >> aux;
                set(TC,i,j,aux);
            }
        }

        cout << "Matriz TC cargada" << endl << endl;
    }
    else // creo tc
    {
        cout << "Creando TC" << endl;
        if (!baseDeDatosCargada)
        {
            ifstream entradaDB;
            entradaDB.open("archivos/matriz.txt");
            if(entradaDB.good() && entradaDB.is_open())
            {
                cout << "Cargando la base de datos" << endl;
                float aux;
                for (int i = 0; i < N; i++)
                {
                    for(int j = 0; j < M; j++)
                    {
                        entradaDB >> aux;
                        if (aux < 50) aux = 0; else aux = 255;
                        set(A,i,j,aux);
                    }
                }
                cout << "Base de datos cargada" << endl;
            }
            else
            {
                cout << "No existe el archivo de la base de datos." << endl << "El programa no puede continuar" << endl;
                int aux;
                cin >> aux;
            }
            entradaDB.close();
        }
        
        // T = Vt * At 
        Matriz *At = Create(M,N);
        traspuesta(A, At);

        Matriz *T = NULL;//Create(M,N);
        T = multiplicar(V, At);

        cout << "Creada TC" << endl;

        Delete(At);

        ofstream escribirTC;
        escribirTC.open ("archivos/TC_C.txt", ofstream::trunc);
        if(escribirTC.good() && escribirTC.is_open())
        {
            for(int i = 0; i < M; i++)
            {
                for(int j = 0; j < N; j++)
                {
                    escribirTC << get(T,i,j) << " ";
                    if (i < K)
                    {
                        set(TC,i,j, (get(T,i,j)) );
                    }
                }
                escribirTC << endl;
            }
            cout << "Tc fue guardada" << endl << endl;
        }
        else
        {
            cout << "Error al crear el archivo TC.txt";
        }
        Delete(T);
        escribirTC.close();
    }
    archivoTC.close(); 
}

void cargarCaracter (Matriz *X) {
    for(int i = 0; i < M; i++)
    {
        set(X,i, 0, vectorImagen[i]);
    }
    cout << "Imagen cargada" << endl << endl;
}

Matriz* Create(const int row_count, const int column_count)
{
    Matriz* m = new Matriz();
    
    m->fila = row_count;
    m->columna = column_count;

    float* p = new float[row_count*column_count];
    m->Vector = p;
    return m;
}

void Delete(Matriz *self)
{
    delete[] self->Vector;

    delete self;
}
    
void cero(Matriz *self)
{
    for(int i = 0; i < cantidadFilas(self); i++)
    {
        for(int j = 0; j < cantidadColumnas(self); j++)
        {
            set(self,i,j,0);
        }
    }
}

void identidad(Matriz *self)
{
    for(int i = 0; i < cantidadFilas(self); i++)
    {
        for(int j = 0; j< cantidadColumnas(self); j++)
        {
            if (i == j)
                set(self,i,j,1);
            else
                set(self,i,j,0);
        }
    } 
}

Matriz* multiplicar(Matriz *self, Matriz *b)
{
    if (cantidadColumnas(self) == cantidadFilas(b))
    {
        Matriz* res = Create(cantidadFilas(self), cantidadColumnas(b));
        cero(res);
        
        for (int r = 0; r < cantidadFilas(self); r++)
        {
            for (int c_res = 0; c_res < cantidadColumnas(b); c_res++)
            {
                for (int c = 0; c < cantidadColumnas(self); c++)
                {
                    float aux = get(self,r,c) * get(b,c,c_res);
                    aux += get(res,r,c_res);
                    set(res,r,c_res,aux);
                }
            }
        }
    
        return res;
    }
    else
    {
        cout << "Error de dimensiones";
        Matriz* res = Create(cantidadFilas(self), cantidadColumnas(self));
        return res;
    }
}

void multiplicarThis(Matriz *self, Matriz *b) //multiplica las matrices y la guarda en self 
{
    Matriz* res = NULL;
    res = multiplicar(self, b);
    copiar(self, res);
    Delete(res);
}

void multiplicarParametro(Matriz *self, Matriz *b) //multiplica las matrices y la guarda en el parametro
{
    Matriz* res = NULL;
    res = multiplicar(self, b);
    copiar(b, res);
    Delete(res);
}

void dividir(Matriz *self, const float v)
{
    for (int r = 0; r < cantidadFilas(self); r++)
    {
        for (int c = 0; c < cantidadColumnas(self); c++)
        {
            float aux = get(self,r,c) / v;
            set(self,r,c,aux);
        }
    }
}

void copiar(Matriz *self, Matriz *b)
{
    for (int r = 0; r < cantidadFilas(self); r++)
    {
        for (int c = 0; c < cantidadColumnas(self); c++)
        {
            float aux = get(b,r,c);
            set(self,r,c,aux);
        }
    } 
}

void traspuesta(Matriz *self, Matriz *res)
{
    for(int i=0; i<cantidadFilas(self); i++)
        for (int j = 0; j < cantidadColumnas(self); j++)
            set(res,j,i, (get(self,i,j)) );
}

void traspuestaCuadrada(Matriz *self)
{
    for(int i=0; i<cantidadFilas(self); i++)
        for (int j = i + 1; j < cantidadColumnas(self); j++)
        {
            float aux = get(self,i,j);
            float aux2 = get(self,j,i);
            set(self,i,j,aux2);
            set(self,j,i,aux);
        }
}

void mediaCero(Matriz *self) 
{
    Matriz *media = Create(1, cantidadColumnas(self));
    cero(media); //coloco el vector en 0
    
    for(int i = 0; i < cantidadFilas(self); i++)
    {
        for(int j = 0; j < cantidadColumnas(self); j++)
        {
            float aux = get(media,0,j) + get(self,i,j);
            set(media,0, j, aux);
        }
    }

    float elem;
    // sume todas las imagenes
    for(int j = 0; j < cantidadColumnas(self); j++)
    {
        float aux = get(media,0,j) / cantidadFilas(self);
        
        for(int i = 0; i < cantidadFilas(self); i++)
        {
            elem = get(self,i,j) - aux;
            set(self,i,j,elem);
        }
    } 
    Delete(media); 
}

void set(Matriz *self, const int row, const int col, float valor)
{
    int posicion = (row * cantidadColumnas(self)) + col;
    float* p = self->Vector;
    (*(p + posicion)) = valor;  //self->Vector[posicion] = valor;
}

float get(Matriz *self, const int row, const int col)
{
    int posicion = (row * cantidadColumnas(self)) + col;
    float* p = self->Vector;
    return *(p + posicion);
}

int cantidadFilas(Matriz *self)
{
    return self->fila;
}

int cantidadColumnas(Matriz *self)
{
    return self->columna;
}

double norma2(Matriz *self)
{
    float res = 0;
    for(int i = 0; i < cantidadFilas(self); i++)
        res+= pow(get(self,i,0),2);
    res = sqrt(res);

    return res;
}

int averiguarDigito(Matriz *self, Matriz *tcX, Matriz *label) // self  =  TC (las 10 TC's)
{
    int res = 0;
    Matriz *digito = Create(K, 1);

    vector< pair<double,int> > vecinos (N);

    for (int i = 0; i < N; ++i) {
        for (int j = 0; j < K; ++j) { // Cargo el digito y le resto la Tc(X)
            float aux = get(self,j,i);
            aux -= get(tcX,j,0);
            set(digito,j,0,aux);
        }

        double norma2deDigitos = norma2(digito);
        pair<double, int> numero;
        numero.first = norma2deDigitos;
        numero.second = get(label, 0, i);
        vecinos[i] = numero;
    }
    make_heap(vecinos.begin(), vecinos.end());
    sort_heap(vecinos.begin(),vecinos.end());
    vector<int> valores(10,0);

    for(int i = 0; i<10; ++i){
        valores[((vecinos[i]).second)]++;
    }

    int comparador = 0;
    for(int i = 0; i<10;++i){
        if (valores[i]>comparador){
            comparador = valores[i];
            res = i;
        }
    }

    Delete(digito);
    return res;

}


void rotacion(Matriz *self, Matriz *Q, int i, int j)
{
    float x1 = get(self,j,j);
    float x2 = get(self,i,j);
    float coseno = x1/sqrt(x1*x1+x2*x2);
    float seno = x2/sqrt(x1*x1+x2*x2);

    // W = W * self coloca un 0 en la posicion i j de self
    /* W es la matriz identidad salvo:
    ii -> coseno; jj -> coseno; ij -> -seno; ji -> seno
    por lo tanto lo unico que varia de la matriz W es la fila i y la fila j */

    for (int k = 0; k < cantidadColumnas(self); ++k) {
        float jk = get(self,j,k);
        float ik = get(self,i,k);
        float aux;

        aux = ((coseno * jk) + (seno * ik));
        set(self,j,k,aux);

        aux = ((coseno * ik) - (seno * jk));
        set(self,i,k,aux);
    }
    set(self,i,j,0); // fuerzo el 0 para evitar errores de calculos

    // Q = W * Q, multiplico todos los w para obtener Q
    // utilizamos el mismo rasonamiento que usamos con self
    for (int k = 0; k < cantidadColumnas(Q); ++k) {
        float jk = get(Q,j,k);
        float ik = get(Q,i,k);
        float aux;

        aux = ((coseno * jk) + (seno * ik));
        set(Q,j,k,aux);

        aux = ((coseno * ik) - (seno * jk));
        set(Q,i,k,aux);
    }
}

void factorizacionQR (Matriz *self, Matriz *Q, float toleranciaNumero) // Usando Givens
{
    identidad(Q);

    for (int j=0; j<cantidadFilas(self) -1;j++){
        for(int i=j+1;i<cantidadFilas(self);i++){
            if(fabs(get(self,i,j))>=toleranciaNumero){
                rotacion(self, Q, i, j);
            }
        }
    }

    // al finalizar los ciclos, self es R 
    // Q * A = R => Qt * Q * A = Qt * R
    traspuestaCuadrada(Q); 
}

void algoritmoQR(Matriz *self, Matriz *V, float toleranciaSumaSuperior, float toleranciaNumero)
{
    Matriz *Qk = Create(M,M);
    Matriz *Rk = Create(M,M);

    identidad(V);
    
    while(! (paradaQR(self, toleranciaSumaSuperior)))
    {
        factorizacionQR(self, Qk, toleranciaNumero); 
        multiplicarThis(self, Qk); // self = self * Qk
        multiplicarThis(V, Qk);  // v = v * Q
    }
    Delete(Qk);
    Delete(Rk);
}

bool paradaQR(Matriz *self, float tol)
{
    float aux = 0;
    for(int i = 1; i < cantidadFilas(self); i++)
    {
        for(int j = 0; j <= i-1; j++)
        {
            aux += abs(get(self,i,j));
        }
    }
    return (tol > aux);
}

Matriz* calcularPromedioTC(Matriz *self, Matriz* label)
{
    Matriz *Tc = Create(M,10);
    Matriz *cantidad = Create(1,10);
    float k = 0;
    float aux;
    cero(cantidad);
    cero(Tc);

    for (int j = 0; j < N; ++j)
    {
        k = get(label,0,j);
        aux = get(cantidad,0,k);
        aux++;
        set(cantidad,0,k,aux);
        
        for (int i = 0; i < M; ++i)
        {
            aux = get(self,i,j);
            aux += get(Tc,i,k);
            set(Tc,i,k,aux);
        }
    }
    for (int j = 0; j < 10; ++j)
    {
        k = get(cantidad,0,j);
        for (int i = 0; i < M; ++i)
        {
            aux = get(Tc,i,j);
            aux = aux/k;
            set(Tc,i,j,aux);
        } 
    }
    Delete(cantidad);
    return Tc;
}
