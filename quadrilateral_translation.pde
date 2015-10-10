import Jama.*;

// Quadrilateral coordinates (top-left, bottom-left, bottom-right, top-right) to transform from
double X1 = 0.;
double Y1 = 0.;
double X2 = 10.;
double Y2 = 40.;
double X3 = 100.;
double Y3 = 35.;
double X4 = 70.;
double Y4 = 0.;

// Rectangle coordinates to transform to (theoretically may be any quadrilateral)
double x1 = 0.;
double y1 = 0.;
double x2 = 0.;
double y2 = 40.;
double x3 = 100.;
double y3 = 40.;
double x4 = 100.;
double y4 = 0.;

Matrix A = new Matrix(new double[][]{
  { x1, y1, 1., 0., 0., 0., (-X1)*x1, (-X1)*y1 },
  { 0., 0., 0., x1, y1, 1., (-Y1)*x1, (-Y1)*y1 },
  { x2, y2, 1., 0., 0., 0., (-X2)*x2, (-X2)*y2 },
  { 0., 0., 0., x2, y2, 1., (-Y2)*x2, (-Y2)*y2 },
  { x3, y3, 1., 0., 0., 0., (-X3)*x3, (-X3)*y3 },
  { 0., 0., 0., x3, y3, 1., (-Y3)*x3, (-Y3)*y3 },
  { x4, y4, 1., 0., 0., 0., (-X4)*x4, (-X4)*y4 },
  { 0., 0., 0., x4, y4, 1., (-Y4)*x4, (-Y4)*y4 }
});

Matrix B = new Matrix(new double[][]{
  { X1 },
  { Y1 },
  { X2 },
  { Y2 },
  { X3 },
  { Y3 },
  { X4 },
  { Y4 }
});

Matrix s = A.solve(B);

Matrix N = new Matrix(new double[][]{
  { s.get(0, 0), s.get(1, 0), s.get(2, 0) },
  { s.get(3, 0), s.get(4, 0), s.get(5, 0) },
  { s.get(6, 0), s.get(7, 0), 1. }
});

/*
  Translates a (x, y) quadrilateral point into (X, Y) rectangle point
*/

double x = 69.;
double y = 1.;

Matrix M = new Matrix(new double[][]{
  { x },
  { y },
  { 1. }
});

Matrix L = N.inverse().times(M);

double X = L.get(0, 0) / L.get(2, 0);
double Y = L.get(1, 0) / L.get(2, 0);

println("From ", x, ",", y, " to ", X, ",", Y);

/*
 * Draws a gradient over a quadrilateral and its translation over a rectangle
 */ 

PImage canvas;
PVector point = new PVector(0, 0);

size(300, 90); 

// Use this polygon to check if a point is inside the poligon
java.awt.Polygon cornersPolygon = new java.awt.Polygon();
cornersPolygon.addPoint(0, 0); // top-left
cornersPolygon.addPoint(70, 0); // top-right
cornersPolygon.addPoint(100, 35); // bottom-right
cornersPolygon.addPoint(10, 40); // bottom-left

// Allocate canvas
canvas = createImage(300, 90, RGB);
canvas.loadPixels();


int i, j, p;
for (j = 0; j < 40; j++) {
  for (i = 0; i < 100; i++) {
    // Offset image by 25 pixels
    p = (j + 25) * 300 + (i + 25);
    if (cornersPolygon.contains(i, j)) {
      // Draw quadrilateral point
      canvas.pixels[p] = color(128 + i, 255 - j, i+j);
      
      // Compute rectangle point
      M = new Matrix(new double[][]{
        { i },
        { j },
        { 1. }
      });
      L = N.inverse().times(M);
      point.x = (float)(L.get(0, 0) / L.get(2, 0));
      point.y = (float)(L.get(1, 0) / L.get(2, 0));
      
      if (point.y >= -25 && point.y < 65 && point.x >= -25 && point.x < 125) {
        // Offset image by 175 and 25 pixels on x and y axis respectively
        canvas.pixels[((int)point.y + 25) * 300 + ((int)point.x + 175)] = color(128 + i, 255 - j, i+j);
      }
    }
  }
} 

// Draw canvas
canvas.updatePixels();
image(canvas, 0, 0);


