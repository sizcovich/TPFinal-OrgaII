#include <QtWidgets>
#include <fstream>
#include "ocr.h"
#include "ui_ocr.h"
#include "matriz.h"
#include "scribblearea.h"
#include "mainwindow.h"
#include <iostream>


using namespace std;

OCR::OCR(QWidget *parent) :
    QWidget(parent),
    ui(new Ui::OCR)
{
    ui->setupUi(this);
    //this->setStyleSheet("background-image: url(./image.jpg)");
    this->setGeometry(0,0,2000,1000);

    Bienvenida = findChild<QWidget*>("Bienvenida");
    Principal = findChild<QWidget*>("Principal");
    CargarBase = findChild<QWidget*>("CargarBase");
    Resultado = findChild<QWidget*>("Resultado");
    Cargando = findChild<QWidget*>("Cargando");

    QImage fondo;
    fondo.load("image.png");
    ui->fondoColor->setPixmap(QPixmap::fromImage(fondo).scaled(2000,1000,Qt::KeepAspectRatio));
    ui->fondoColor->show();
    Principal->setEnabled(false);
    Principal->setVisible(false);
    //Principal->setStyleSheet("background-image: url(./image.jpg)");
    Principal->setGeometry(0,0,2000,1000);
    CargarBase->setEnabled(false);
    CargarBase->setVisible(false);
    //CargarBase->setStyleSheet("background-image: url(./image.jpg)");
    CargarBase->setGeometry(0,0,2000,1000);
    Resultado->setEnabled(false);
    Resultado->setVisible(false);
    //Resultado->setStyleSheet("background-image: url(./image.jpg)");
    Resultado->setGeometry(0,0,2000,1000);
    Cargando->setEnabled(false);
    Cargando->setVisible(false);
    //Cargando->setStyleSheet("background-image: url(./image.jpg)");
    Cargando->setGeometry(0,0,2000,1000);
    ui->errorK->setVisible(false);
    ui->errorN->setVisible(false);
    ui->errorM->setVisible(false);
    ui->errorOpcion->setVisible(false);
    ui->errorParametros->setVisible(false);
    ui->Asm->setChecked(true);

    ifstream archivoDatos;
    archivoDatos.open("archivos/Datos.txt");
    if(archivoDatos.good() && archivoDatos.is_open())
    {
        QString str;
        archivoDatos >> N;
        archivoDatos >> M;
        archivoDatos >> K;
        archivoDatos >> M_X;
        archivoDatos >> M_Y;

        ui->M_x->setText(str.setNum(M_X));
        ui->M_y->setText(str.setNum(M_Y));
        ui->N->setText(str.setNum(N));
        ui->K->setText(str.setNum(K));
        ui->x->setText(str.setNum(M_X));
        ui->y->setText(str.setNum(M_Y));
        ui->tprecision->setText(str.setNum(K));
        ui->cant_imagenes->setText(str.setNum(N));

        puedoProcesarBase = true;
    }
    archivoDatos.close();

    ifstream baseProcesada;
    baseProcesada.open("archivos/Vt.txt");
    if(baseProcesada.good() && baseProcesada.is_open())
    {
        datosCargados = true;
        ui->baseDeDatosCargada->setText("SI");
    }
    else
    {
        datosCargados = false;
        ui->baseDeDatosCargada->setText("NO");
    }
    baseProcesada.close();
}

OCR::~OCR()
{
    delete ui;
}

void OCR::on_BotonEmpezar_clicked()
{
    Principal->setEnabled(true);
    Principal->setVisible(true);
    Bienvenida->setEnabled(false);
    Bienvenida->setVisible(false);
}

void OCR::on_cargarBase_clicked()
{
    CargarBase->setEnabled(true);
    CargarBase->setVisible(true);
    Principal->setEnabled(false);
    Principal->setVisible(false);
}

void OCR::on_crearImagen_clicked()
{
    mw = new MainWindow();
    mw->show();
}

void OCR::on_CargarImagen_clicked(){
    nombreDeLaImagen = QFileDialog::getOpenFileName(this,tr("Abrir Imagen"), QDir::currentPath() + "/imagenes", tr("Image Files (*.png *.jpg *.bmp)"));
    imagenCargada = true;
}

void OCR::on_Aceptar_clicked()
{
    bool ok;
    int Naux = ui->cant_imagenes->toPlainText().toInt(&ok,10);
    int valor_x = ui->x->toPlainText().toInt(&ok,10);
    int valor_y = ui->y->toPlainText().toInt(&ok,10);
    int Maux = valor_x * valor_y;
    int Kaux = ui->tprecision->toPlainText().toInt(&ok,10);

    QString str;

    ok = true;

    if (Kaux < 0 || Kaux > Maux)
    {
        ui->errorK->setVisible(true);
        ok = false;
    }
    else {
        ui->errorK->setVisible(false);
    }

    if (Maux <= 0)
    {
        ui->errorM->setVisible(true);
        ok = false;
    }
    else {
        ui->errorM->setVisible(false);
    }

    if (Naux <= 0)
    {
        ui->errorN->setVisible(true);
        ok = false;
    }
    else {
        ui->errorN->setVisible(false);
    }

    if (ok)
    {
        if (Naux != N || Maux != M)
            datosCargados = false;

        M = Maux;
        N = Naux;
        K = Kaux;
        M_X = valor_x;
        M_Y = valor_y;

        ui->M_x->setText(str.setNum(M_X));
        ui->M_y->setText(str.setNum(M_Y));
        ui->N->setText(str.setNum(N));
        ui->K->setText(str.setNum(K));

        if (datosCargados)
            ui->baseDeDatosCargada->setText("SI");
        else
            ui->baseDeDatosCargada->setText("NO");


        Principal->setEnabled(true);
        Principal->setVisible(true);
        CargarBase->setEnabled(false);
        CargarBase->setVisible(false);
        ui->errorN->setVisible(false);
        ui->errorM->setVisible(false);
        ui->errorK->setVisible(false);
        puedoProcesarBase = true;
    }
}

void OCR::on_Cancelar_clicked()
{

    Principal->setEnabled(true);
    Principal->setVisible(true);
    CargarBase->setEnabled(false);
    CargarBase->setVisible(false);
}

void OCR::on_otroDigito_clicked()
{
    Principal->setEnabled(true);
    Principal->setVisible(true);
    Resultado->setEnabled(false);
    Resultado->setVisible(false);

    semaphore = true;
    datosCargados = true;
    ui->baseDeDatosCargada->setText("SI");
}

void OCR::on_averiguarDigito_clicked()
{
    bool ok = true;
    QString str;

    ok = (ui->C->isChecked() || ui->Asm->isChecked());

    if (ok == false)
        ui->errorOpcion->setVisible(true);
    else
        ui->errorOpcion->setVisible(false);

    ok = (ok && puedoProcesarBase);

    if (!puedoProcesarBase)
        ui->errorParametros->setVisible(true);
    else
        ui->errorParametros->setVisible(false);

    ok = (ok && imagenCargada);

    if (!imagenCargada)
        ui->errorParametros->setVisible(true);
    else
        ui->errorParametros->setVisible(false);

    if(ok)
    {
        Cargando->setEnabled(true);
        Cargando->setVisible(true);
        Principal->setEnabled(false);
        Principal->setVisible(false);

        ui->barraDeProgreso->setValue(0);

        if (!datosCargados) {
            remove("archivos/Vt.txt");
            remove("archivos/TC_C.txt");
            remove("archivos/TC_ASM.txt");


            ofstream escribirDatos;
            escribirDatos.open ("archivos/Datos.txt", ofstream::trunc);
            if(escribirDatos.good() && escribirDatos.is_open())
            {
                escribirDatos << N << " " << M << " " << K << " " << M_X << " " << M_Y;
            }
            escribirDatos.close();
        }

        QImage myImage;
        myImage.load(nombreDeLaImagen);

        int ancho = M_X;
        int alto = M_Y;
        int var;
        int dim = ancho*alto;

        vectorImagen.resize(dim);
        QRgb valor;
        for(int i = 0; i < ancho; ++i){
            for(int j = 0; j<alto; ++j){
                var = ((i)+((j)*ancho));
                valor = myImage.pixel(j,i);
                vectorImagen[var] = qGray(valor);
                if (vectorImagen[var] < 50) vectorImagen[var] = 0; else vectorImagen[var] = 255;
            }
            cout << endl;
        }
        mostrarImagen = myImage;

        //programa
        if (ui->C->isChecked())
        {
            Matriz *Vt = Create(K,M);  // Tiene los primeros k autovectores de V
            Matriz *A = Create(N,M);   // Base de datos
            Matriz *TC = Create(K,N);  // Tiene las tc de la base de datos (una por cada digito)
            Matriz *V = Create(M,M); // Tiene a toda la matriz V (los autovectores estan colocados como filas)
            Matriz *label = Create(1,N);  // Indica a que digito pertenece cada imagen
            Matriz *X = Create(M, 1); // Imagen a descubrir

            cargarLabel(label); // cargo label para usarlo en Tc

            ui->estado->setText("Etiquetas cargadas"); ui->barraDeProgreso->setValue(10);

            cargarVt(V, Vt, A, &baseDeDatosCargada); // cargo Vt y V

            ui->estado->setText("Base de datos procesada"); ui->barraDeProgreso->setValue(70);

            cargarTc(TC, baseDeDatosCargada, A, V); // cargo TC.

            ui->estado->setText("Transformada característica Procesada"); ui->barraDeProgreso->setValue(90);

            /*
                1) Leo de un archivo el vector X ( Matriz *X = Create(M,1); )
                2) tcX = V * X. Esto me da Tc(X), el resultado esta como un vector "parado"
                3) Comparo tcX con los 10 TC que tenia. Esta comparacion la hago usando la norma 2 y quedandome con la mas chica
            */

            cargarCaracter(X);

            ui->estado->setText("Caracter cargado"); ui->barraDeProgreso->setValue(95);

            Matriz *tcX = NULL;//Create(K, 1);
            tcX = multiplicar(Vt, X);

            int resultado = averiguarDigito(TC, tcX, label); // Le paso las TC y la tc de la imagen para que compare sus normas 2

            Resultado->setEnabled(true);
            Resultado->setVisible(true);
            Cargando->setEnabled(false);
            Cargando->setVisible(false);
            ui->imagen->setPixmap(QPixmap::fromImage(mostrarImagen).scaled(ui->imagen->width(),ui->imagen->height(),Qt::KeepAspectRatio));
            ui->imagen->show();

            ui->res->setText(str.setNum(resultado,10));

            Delete(label);
            Delete(Vt);
            Delete(TC);
            Delete(X);
            Delete(A);
            Delete(V);
            Delete(tcX);
        }
        else {
            Matriz *Vt = matriz_create(K,M);  // Tiene los primeros k autovectores de V
            Matriz *A = matriz_create(N,M);   // Base de datos
            Matriz *TC = matriz_create(K,N);  // Tiene las tc de la base de datos (una por cada digito)
            Matriz *V = matriz_create(M,M); // Tiene a toda la matriz V (los autovectores estan colocados como filas)
            Matriz *label = matriz_create(1,N);  // Indica a que digito pertenece cada imagen
            Matriz *X = matriz_create(M, 1); // Imagen a descubrir

            cargarLabel_asm(label); // cargo label para usarlo en Tc

            ui->estado->setText("Etiquetas cargadas"); ui->barraDeProgreso->setValue(10);

            cargarVt_asm(V, Vt, A, &baseDeDatosCargada); // cargo Vt y V

            ui->estado->setText("Base de datos procesada"); ui->barraDeProgreso->setValue(70);

            cargarTc_asm(TC, baseDeDatosCargada, A, V); // cargo TC.

            ui->estado->setText("Transformada característica Procesada"); ui->barraDeProgreso->setValue(90);

            /*
                1) Leo de un archivo el vector X ( Matriz *X = matriz_create(M,1); )
                2) tcX = V * X. Esto me da Tc(X), el resultado esta como un vector "parado"
                3) Comparo tcX con los TC que tenia. Esta comparacion la hago usando la norma 2 y quedandome con la mas chica
            */

            cargarCaracter_asm(X);

            ui->estado->setText("Caracter cargado"); ui->barraDeProgreso->setValue(95);

            Matriz *tcX = NULL;//matriz_create(K, 1);
            tcX = matriz_multiplicar(Vt, X);

            int resultado = averiguarDigito_asm(TC, tcX, label); // Le paso las TC y la tc de la imagen para que compare sus normas 2

            Resultado->setEnabled(true);
            Resultado->setVisible(true);
            Cargando->setEnabled(false);
            Cargando->setVisible(false);
            ui->imagen->setPixmap(QPixmap::fromImage(mostrarImagen).scaled(ui->imagen->width(),ui->imagen->height(),Qt::KeepAspectRatio));
            ui->imagen->show();

            ui->res->setText(str.setNum(resultado,10));

            matriz_delete(label);
            matriz_delete(Vt);
            matriz_delete(TC);
            matriz_delete(X);
            matriz_delete(A);
            matriz_delete(V);
            matriz_delete(tcX);
        }
        datosCargados = true;
        ui->baseDeDatosCargada->setText("SI");
    }
}


