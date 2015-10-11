import Jama.*;

class QuadRectTransform {
  public QuadRectTransform(PVector q1, PVector q2, PVector q3, PVector q4,
                   PVector r1, PVector r2, PVector r3, PVector r4) {

    Matrix A = new Matrix(new double[][]{
      { r1.x, r1.y, 1., 0., 0., 0., (-q1.x)*r1.x, (-q1.x)*r1.y },
      { 0., 0., 0., r1.x, r1.y, 1., (-q1.y)*r1.x, (-q1.y)*r1.y },
      { r2.x, r2.y, 1., 0., 0., 0., (-q2.x)*r2.x, (-q2.x)*r2.y },
      { 0., 0., 0., r2.x, r2.y, 1., (-q2.y)*r2.x, (-q2.y)*r2.y },
      { r3.x, r3.y, 1., 0., 0., 0., (-q3.x)*r3.x, (-q3.x)*r3.y },
      { 0., 0., 0., r3.x, r3.y, 1., (-q3.y)*r3.x, (-q3.y)*r3.y },
      { r4.x, r4.y, 1., 0., 0., 0., (-q4.x)*r4.x, (-q4.x)*r4.y },
      { 0., 0., 0., r4.x, r4.y, 1., (-q4.y)*r4.x, (-q4.y)*r4.y }
    });

    Matrix B = new Matrix(new double[][]{
      { q1.x },
      { q1.y },
      { q2.x },
      { q2.y },
      { q3.x },
      { q3.y },
      { q4.x },
      { q4.y }
    });

    Matrix s = A.solve(B);

    rect2quadMat = new Matrix(new double[][]{
      { s.get(0, 0), s.get(1, 0), s.get(2, 0) },
      { s.get(3, 0), s.get(4, 0), s.get(5, 0) },
      { s.get(6, 0), s.get(7, 0), 1. }
    });

    quad2rectMat = rect2quadMat.inverse();
  }

  /*
  Translates a (x, y) quadrilateral point into (X, Y) rectangle point
  */
  public PVector quad2rect(PVector v) {
    return transform(quad2rectMat, v);
  }

  /*
  Translates a (X, Y) rectangle point into (x, y) quadrilateral point
  */
  public PVector rect2quad(PVector v) {
    return transform(rect2quadMat, v);
  }

  private PVector transform(Matrix transformMat, PVector v) {
    Matrix columnVec = new Matrix(new double[][]{
      { v.x },
      { v.y },
      { 1. }
    });

    Matrix result = transformMat.times(columnVec);

    return new PVector(new Float(result.get(0, 0) / result.get(2, 0)),
                       new Float(result.get(1, 0) / result.get(2, 0)));
  }


  private Matrix rect2quadMat;
  private Matrix quad2rectMat;
}


PVector q1, q2, q3, q4, r1, r2, r3, r4;

// Quadrilateral coordinates (top-left, bottom-left, bottom-right, top-right) to transform from
q1 = new PVector(0, 0);
q2 = new PVector(10, 40);
q3 = new PVector(100, 35);
q4 = new PVector(70, 0);


// Rectangle coordinates to transform to (theoretically may be any quadrilateral)
r1 = new PVector(0, 0);
r2 = new PVector(0, 40);
r3 = new PVector(100, 40);
r4 = new PVector(100, 0);

PVector v = new PVector(69, 1);

QuadRectTransform t = new QuadRectTransform(q1, q2, q3, q4, r1, r2, r3, r4);

PVector u = t.quad2rect(v);

println("From ", v.x, ",", v.y, " to ", u.x, ",", u.y);

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
      point = t.quad2rect(new PVector(i, j));

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


