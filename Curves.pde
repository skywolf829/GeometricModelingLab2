abstract class Curve {
  public boolean closed = false;
  public ArrayList<Point> controlPoints;
  public ArrayList<Point> approximatePoints;
  public abstract void approximateCurve(double[] args);
  public void draw() {
    for (int i = 0; i < approximatePoints.size() - 1; i++) {
      line((int)approximatePoints.get(i).x, (int)approximatePoints.get(i).y, 
        (int)approximatePoints.get(i+1).x, (int)approximatePoints.get(i+1).y);
    }
    stroke(255);
  }
}


//Bezier curve - one curve for all the points
class BezierCurve extends Curve {

  public BezierCurve() {
    controlPoints = new ArrayList<Point>();
    approximatePoints = new ArrayList<Point>();
  }
  public Point SolveAtParameterBernstein(float u) {
    Point p = new Point(0, 0);
    for (int i = 0; i < controlPoints.size(); i++) {
      p.x += controlPoints.get(i).x * nChoosek(controlPoints.size() - 1, i) * 
        pow(u, i) * pow(1 - u, controlPoints.size() - i - 1);
      p.y += controlPoints.get(i).y * nChoosek(controlPoints.size() - 1, i) * 
        pow(u, i) * pow(1 - u, controlPoints.size() - i - 1);
    }
    p.circle.x = (int)p.x;
    p.circle.y = (int)p.y;
    return p;
  }
  void closeCurve() {
    if (controlPoints.size() > 2) {
      Point first = controlPoints.get(0);
      Point second = controlPoints.get(1);
      controlPoints.add(new Point(lerp(first.x, second.x, -1.5), 
        lerp(first.y, second.y, -1.5), lerp(first.z, second.z, -1.5)));
      controlPoints.add(first);
    }
  }

  public void approximateCurve(double[] args) {
    approximatePoints = new ArrayList<Point>();
    if (closed) closeCurve();
    for (float i = 0.0; i <= 1; i += 1.0 / args[0]) {
      approximatePoints.add(SolveAtParameterBernstein(i));
    }
  }

  public Mesh approximateRevolution(double[] args, char dimension) {
    ArrayList<Point> vertices = new ArrayList<Point>();
    ArrayList<ArrayList<Integer>> ASCIIfaces = new ArrayList<ArrayList<Integer>>();
    // Sample each point on the curve
    for (float i = 0; i <= 1; i += 1 / args[0]) {
      Point p = SolveAtParameterBernstein(i);
      // Create args[1] points rotated about the desired axis
      for (float j = 0; j < 2 * PI; j += (2 * PI) / args[1]) {
        double x = 0, y=0, z=0;
        if (dimension == 'x') {
          z = p.y * sin(j);
          x = p.x;
          y = p.y * cos(j);
        } else if (dimension == 'y') {
          z = p.x * sin(j);
          y = p.y;
          x = p.x * cos(j);
        }
        vertices.add(new Point(x, y, z));
      }
    }
    if(closed){
     while(vertices.size() > args[0] * args[1]){
      vertices.remove(vertices.size() - 1); 
     }
    }
    for (int i = 0; i < args[0] * args[1]; i++) {
      ArrayList<Integer> temp = new ArrayList<Integer>();
      temp.add(i);
      temp.add((i / ((int)(args[1]))) * ((int)(args[1])) + 
        (i+1) % ((int)args[1])); //% ((int)(args[0] * args[1])));
      temp.add(((i / ((int)(args[1]))) * ((int)(args[1])) + 
        (i+1) % ((int)args[1]) + ((int)args[1])));// % ((int)(args[0] * args[1])));
      temp.add((i + ((int)args[1])));// % ((int)(args[0] * args[1])));
      
      if(closed){
        temp.add(0, temp.get(0)% ((int)(args[0] * args[1])));
        temp.remove(1);
        temp.add(1, temp.get(1)% ((int)(args[0] * args[1])));
        temp.remove(2);
        temp.add(2, temp.get(2)% ((int)(args[0] * args[1])));
        temp.remove(3);
        temp.add(3, temp.get(3)% ((int)(args[0] * args[1])));
        temp.remove(4);
      }
      ASCIIfaces.add(temp);
    }
    return new Mesh(vertices, ASCIIfaces);
  }
}

//Cubic B-spline with uniform knot vector.
class BSpline extends Curve {
  int D;
  public BSpline() {
    controlPoints = new ArrayList<Point>();
    approximatePoints = new ArrayList<Point>();
  }
  public void approximateCurve(double[] args) {
    ArrayList<Point> cpsave = controlPoints;
    int n = cpsave.size();
    for (int j = 0; j < n; j++) {
      for (int i = 1; i < args[1]; i++) {
        controlPoints.add(j * (int)args[1], controlPoints.get(j * (int)args[1]));
      }
    }
    D = (int)args[0];
    approximatePoints = new ArrayList<Point>();

    for (float i = 0.0; i <= controlPoints.size() - D + 1; i+=.01) {
      approximatePoints.add(SolveAt(i, D));
    }
    controlPoints = cpsave;
  }
  public Point SolveAt(double u, int D) {
    Point p = new Point(0, 0);


    for (int i = 0; i < controlPoints.size(); i++) {
      p.x += controlPoints.get(i).x * basisFunction(i, D, u);
      p.y += controlPoints.get(i).y * basisFunction(i, D, u);
    }

    return p;
  }
  public float getT(int j) {

    if (D <= j && j <= controlPoints.size()-1) {
      return j-D+1;
    }
    if (controlPoints.size() - 1 < j && j <= controlPoints.size()-1+D) {
      return controlPoints.size()-D+1;
    } else {
      return 0;
    }
  }
  double uniformBasisFunction(int i, int d, double u) {
    if (d == 1) {
      if (i <= u && 
        u < i+1) return 1;
      else return 0;
    } else {
      double leftSide, rightSide;

      leftSide = ((u-i) * uniformBasisFunction(i, d-1, u)) /
        ((float)(d-1));
      rightSide = ((i+d-u) * uniformBasisFunction(i+1, d-1, u)) /
        ((float)(d-1));

      return leftSide + rightSide;
    }
  }
  double basisFunction(int i, int d, double u) {
    if (d == 1) {
      if (getT(i) <= u && 
        u < getT(i+1)) return 1;
      else return 0;
    } else {
      double leftSide, rightSide;
      if (getT(i+d-1) == 
        getT(i)) {
        leftSide = 0;
      } else {
        leftSide = ((u - getT(i)) * basisFunction(i, d-1, u)) /
          (getT(i+d-1) - getT(i));
      }
      if (getT(i+d) == 
        getT(i+1)) {
        rightSide = 0;
      } else {
        rightSide = ((getT(i+d) - u) * basisFunction(i+1, d-1, u) /
          (getT(i+d) - getT(i+1)));
      }
      return leftSide + rightSide;
    }
  }
}

//Subdivision curves using repeated de Casteljau method.
class SubdivisionCurve extends Curve {
  public SubdivisionCurve() {
    controlPoints = new ArrayList<Point>();
    approximatePoints = new ArrayList<Point>();
  }
  public void approximateCurve(double[] args) {
    approximatePoints = subdivide(controlPoints, (int)args[0], 0.5);
  }
  private ArrayList<Point> oneSubdivide(ArrayList<Point> points, 
    ArrayList<Point> poly1, ArrayList<Point> poly2, double u) {
    if (points.size() == 1) {
      ArrayList<Point> toReturn = new ArrayList<Point>();
      for (int i = 0; i < poly1.size(); i++) {
        toReturn.add(poly1.get(i));
      }
      toReturn.add(points.get(0));
      for (int i = 0; i < poly2.size(); i++) {
        toReturn.add(poly2.get(i));
      }
      return toReturn;
    } else {
      poly1.add(points.get(0));
      poly2.add(0, points.get(points.size() - 1));
      ArrayList<Point> newPoints = new ArrayList<Point>();
      for (int i = 0; i < points.size() - 1; i++) {
        newPoints.add(new Point(
          points.get(i).x + u * (points.get(i+1).x - points.get(i).x), 
          points.get(i).y + u * (points.get(i+1).y - points.get(i).y))
          );
      }
      return oneSubdivide(newPoints, poly1, poly2, u);
    }
  }
  ArrayList<Point> subdivide(ArrayList<Point> points, int m, double u) {
    if (m == 1) return oneSubdivide(points, new ArrayList<Point>(), new ArrayList<Point>(), u); 
    else {
      ArrayList<Point> newPoints = oneSubdivide(points, new ArrayList<Point>(), new ArrayList<Point>(), u); 
      ArrayList<Point> p1Points = new ArrayList<Point>();
      ArrayList<Point> p2Points = new ArrayList<Point>();

      for (int i = 0; i <= (newPoints.size() - 1) / 2; i++) {
        p1Points.add(newPoints.get(i));
      }
      for (int i = (newPoints.size() - 1) / 2; i < newPoints.size(); i++) {
        p2Points.add(newPoints.get(i));
      }


      ArrayList<Point> p1 = subdivide(p1Points, m-1, u);
      ArrayList<Point> p2 = subdivide(p2Points, m-1, u);
      ArrayList<Point> toReturn = new ArrayList<Point>();
      for (int i = 0; i < p1.size(); i++) {
        toReturn.add(p1.get(i));
      }
      for (int i = 0; i < p2.size(); i++) {
        toReturn.add(p2.get(i));
      }
      return toReturn;
    }
  }
}

//Subdivision Quadric B-spline with uniform knot vector.
class SubdivisionQuadraticBSpline extends Curve {
  public SubdivisionQuadraticBSpline() {
  }
  public void approximateCurve(double[] args) {
    approximatePoints = new ArrayList<Point>();
    approximatePoints = controlPoints;
    for (int i = 0; i < args[0]; i ++) {
      approximatePoints = subdivide(approximatePoints);
    }
  }
  ArrayList<Point> subdivide(ArrayList<Point> points) {
    ArrayList<Point> newPoints = new ArrayList<Point>();
    for (int i = 1; i < points.size() - 1; i++) {
      Point q1 = new Point(0, 0);
      Point q2 = new Point(0, 0);
      Point r1 = new Point(0, 0);
      Point r2 = new Point(0, 0);
      if (i == 1) {
        q1.x = (3 / 4.0) * points.get(i-1).x + (1 / 4.0) * points.get(i).x;
        q1.y = (3 / 4.0) * points.get(i-1).y + (1 / 4.0) * points.get(i).y;

        q2.x = (1 / 4.0) * points.get(i-1).x + (3 / 4.0) * points.get(i).x;
        q2.y = (1 / 4.0) * points.get(i-1).y + (3 / 4.0) * points.get(i).y;
      }
      r1.x = (3 / 4.0) * points.get(i).x + (1 / 4.0) * points.get(i+1).x;
      r1.y = (3 / 4.0) * points.get(i).y + (1 / 4.0) * points.get(i+1).y;

      r2.x = (1 / 4.0) * points.get(i).x + (3 / 4.0) * points.get(i+1).x;
      r2.y = (1 / 4.0) * points.get(i).y + (3 / 4.0) * points.get(i+1).y;

      if (i == 1) {
        newPoints.add(q1);
        newPoints.add(q2);
      }
      newPoints.add(r1);
      newPoints.add(r2);
    }
    return newPoints;
  }
}