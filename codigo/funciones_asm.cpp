#include <iostream>
#include <cmath>
#include <limits>
#include <fstream>
#include <vector>
#include "matriz.h"

using namespace std;


void cargarLabel_asm (Matriz *label) {
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

void cargarVt_asm (Matriz *V, Matriz *Vt, Matriz *A, bool *baseDeDatosCargada) {
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

            Matriz *base = matriz_create(N,M); 
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
            matriz_mediaCero(base);

            Matriz *Xt = matriz_create(cantidadColumnas(base), cantidadFilas(base));
            matriz_traspuesta(base, Xt);
            Matriz *E = NULL; //Create(cantidadColumnas(base), cantidadColumnas(base));

            E = matriz_multiplicar(Xt, base);
            matriz_dividir(E, N-1);
            matriz_delete(base);
            matriz_delete(Xt);

            cout << "Creada Xt * X" << endl;

            /*Algoritmo QR*/
            float toleranciaSumaSuperior = 20000; //fija una tolerancia para los elementos que estan en la triangular inferior de R.
            float toleranciaNumero = 0.00001;

            algoritmoQR_asm(E,V,toleranciaSumaSuperior, toleranciaNumero); 
            matriz_delete(E);

            matriz_traspuestaCuadrada(V);
            // en V quedan los autovectores de Xt * X como filas

            // guardar V
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

void cargarTc_asm (Matriz *TC, bool baseDeDatosCargada, Matriz *A, Matriz *V) {
    ifstream archivoTC;
    archivoTC.open("archivos/TC_ASM.txt");
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
    else // crear tc
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
        Matriz *At = matriz_create(M,N);
        matriz_traspuesta(A, At);

        Matriz *T = NULL;//Create(M,N);
        T = matriz_multiplicar(V, At);

        cout << "Creada TC" << endl;

        matriz_delete(At);

        ofstream escribirTC;
        escribirTC.open ("archivos/TC_ASM.txt", ofstream::trunc);
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
        matriz_delete(T);
        escribirTC.close();
    }
    archivoTC.close();
}

void cargarCaracter_asm (Matriz *X) {
    for(int i = 0; i < M; i++)
    {
        set(X,i, 0, vectorImagen[i]);
    }
    cout << "Imagen cargada" << endl << endl;
}

void multiplicarThis_asm(Matriz *self, Matriz *b) //multiplica las matrices y la guarda en self 
{
    Matriz* res = NULL;
    res = matriz_multiplicar(self, b);

    matriz_copiar(self, res);
    matriz_delete(res);
}

void multiplicarParametro_asm(Matriz *self, Matriz *b) //multiplica las matrices y la guarda en el parametro
{
    Matriz* res = NULL;
    res = matriz_multiplicar(self, b);
    
    matriz_copiar(b, res);
    matriz_delete(res);
}

int averiguarDigito_asm(Matriz *self, Matriz *tcX, Matriz *label) // self  =  TC
{
    int res = 0;
    Matriz *digito = matriz_create(K, 1);

    vector< pair<double,int> > vecinos (N);
    
    for (int i = 0; i < N; ++i) {
        for (int j = 0; j < K; ++j) { // Carga el digito y le resto la Tc(X)
            float aux = get(self,j,i);
            aux -= get(tcX,j,0);
            set(digito,j,0,aux);
        }

        double norma2deDigitos = matriz_norma2(digito);
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

    matriz_delete(digito);
    return res;
}

void factorizacionQR_asm (Matriz *self, Matriz *Q, float toleranciaNumero) // Usando Givens
{
    matriz_identidad(Q);

    for (int j=0; j<cantidadFilas(self) -1;j++){
        for(int i=j+1;i<cantidadFilas(self);i++){
            if(fabs(get(self,i,j))>=toleranciaNumero){
                matriz_rotacion(self, Q, i, j);
            }
        }
    }
    // al finalizar los ciclos, self es R 
    // Q * A = R => Qt * Q * A = Qt * R

    matriz_traspuestaCuadrada(Q);
}

void algoritmoQR_asm (Matriz *self, Matriz *V, float toleranciaSumaSuperior, float toleranciaNumero)
{
    Matriz *Qk = matriz_create(M,M);
    Matriz *Rk = matriz_create(M,M);

    matriz_identidad(V);

    while(! (paradaQR_asm(self, toleranciaSumaSuperior)))
    {
        factorizacionQR_asm(self, Qk, toleranciaNumero); 
        multiplicarThis_asm(self, Qk); // self = self * Qk
        multiplicarThis_asm(V, Qk);  // v = v * Q
    }

    matriz_delete(Qk);
    matriz_delete(Rk);
}

bool paradaQR_asm(Matriz *self, float tol)
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

Matriz* calcularPromedioTC_asm(Matriz *self, Matriz* label)
{
    Matriz *Tc = matriz_create(M,10);
    Matriz *cantidad = matriz_create(1,10);
    
    float k = 0;
    float aux;

    matriz_cero(cantidad);
    matriz_cero(Tc);

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

    matriz_delete(cantidad);

    return Tc;
}
