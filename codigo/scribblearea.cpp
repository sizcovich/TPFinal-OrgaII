#include <QtWidgets>
#ifndef QT_NO_PRINTER
#include <QPrinter>
#include <QPrintDialog>
#endif
#include<iostream>
#include "scribblearea.h"
#include "matriz.h"

using namespace std;

ScribbleArea::ScribbleArea(QWidget *parent)
    : QWidget(parent)
{
    setAttribute(Qt::WA_StaticContents);
    scribbling = false;
    myPenWidth = 25;
    myPenColor = Qt::white;
}


bool ScribbleArea::saveImage(const QString &fileName, const char *fileFormat)
{
    QImage visibleImage = image;
    resizeImage2(&visibleImage);
    if (visibleImage.save(QDir::currentPath() + fileName, fileFormat)) {
        semaphore = false;
         return true;
    } else {
        return false;
    }
}

void ScribbleArea::setPenColor(const QColor &newColor)
{
    myPenColor = newColor;
}

void ScribbleArea::setPenWidth(int newWidth)
{
    myPenWidth = newWidth;
}

void ScribbleArea::clearImage()
{
    image.fill(qRgb(0, 0, 0));
    update();
}

void ScribbleArea::mousePressEvent(QMouseEvent *event)
{
    if (event->button() == Qt::LeftButton) {
        lastPoint = event->pos();
        scribbling = true;
    }
}

void ScribbleArea::mouseMoveEvent(QMouseEvent *event)
{
    if ((event->buttons() & Qt::LeftButton) && scribbling)
        drawLineTo(event->pos());
}

void ScribbleArea::mouseReleaseEvent(QMouseEvent *event)
{
    if (event->button() == Qt::LeftButton && scribbling) {
        drawLineTo(event->pos());
        scribbling = false;
    }
}

void ScribbleArea::paintEvent(QPaintEvent *event)
{
    QPainter painter(this);
    QRect dirtyRect = event->rect();
    painter.drawImage(dirtyRect.topLeft(), image, dirtyRect);
}

void ScribbleArea::resizeEvent(QResizeEvent *event)
{
    if (width() > image.width() || height() > image.height()) {
        int newWidth = qMax(width(), image.width());
        int newHeight = qMax(height(), image.height());
        resizeImage(&image, QSize(newWidth, newHeight));
        update();
    }
    QWidget::resizeEvent(event);
}

void ScribbleArea::drawLineTo(const QPoint &endPoint)
{
    QPainter painter(&image);
    painter.setPen(QPen(myPenColor, myPenWidth, Qt::SolidLine, Qt::RoundCap,
                        Qt::RoundJoin));
    painter.drawLine(lastPoint, endPoint);

    int rad = (myPenWidth / 2) + 2;
    update(QRect(lastPoint, endPoint).normalized()
                                     .adjusted(-rad, -rad, +rad, +rad));
    lastPoint = endPoint;
}


void ScribbleArea::resizeImage2(QImage *img)
{
    //busco los extremos del numero
    int maxX = 0;
    int maxY = 0;
    int minX = img->width();
    int minY = img->height();

    for (int i = 0; i < img->width(); i++) {
        for (int j = 0; j < img->height(); j++) {
            int color = qGray(img->pixel(i,j));
            if (color >= 50) {
                if (maxX < i)
                    maxX = i;
                if (maxY < j)
                    maxY = j;
                if (minX > i)
                    minX = i;
                if (minY > j)
                    minY = j;
            }
        }
    }

    //obtengo el numero y lo reduzco a 20x20
    QImage newImage = img->copy(minX, minY, maxX-minX, maxY-minY);

    const QSize newSize = QSize(20, 20);
    QImage small = newImage.scaled(newSize,Qt::KeepAspectRatio);

    vector<int> pxcoordx;
    vector<int> pxcoordy;
    for (int i = 0; i < small.width(); i++)
    {
        for (int j = 0; j < small.height(); j++)
        {
            if (small.pixel(i,j) >= 50)
            {
                pxcoordx.push_back(i);
                pxcoordy.push_back(j);
            }
        }
    }

    int promediox = 0;
    int promedioy = 0;
    for (int i = 0; i < pxcoordx.size(); i++)
    {
        promediox += pxcoordx[i];
        promedioy += pxcoordy[i];
    }

    //coordenadas del centro de masa
    promediox /= pxcoordx.size();
    promedioy /= pxcoordx.size();

    //centro la imagen y genero el padding
    img->fill(qRgb(0, 0, 0));
    const QSize Size = QSize(28, 28);
    QImage finishImage = img->scaled(Size,Qt::IgnoreAspectRatio);

    int alto = 14 - promedioy;
    int ancho = 14 - promediox;

    if (alto <= 0)
        alto = 1;
    if (ancho <= 0)
        ancho = 1;

    for (int i = ancho; i < small.width()+ancho; i++) {
        for (int j = alto; j < small.height()+alto; j++) {
           finishImage.setPixel(i,j,small.pixel(i-ancho,j-alto));
        }
    }
    *img = finishImage;
}

void ScribbleArea::resizeImage(QImage *image, const QSize &newSize)
{
    if (image->size() == newSize)
            return;

        QImage newImage(newSize, QImage::Format_RGB32);
        newImage.fill(qRgb(0, 0, 0));
        QPainter painter(&newImage);
        painter.drawImage(QPoint(0, 0), *image);
        *image = newImage;
}
