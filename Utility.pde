
class Face {
  public int numVertices;
  public ArrayList<Point> vertices = new ArrayList<Point>();
  public Face(ArrayList<Point> vertices) {
    this.vertices = vertices;
    numVertices = vertices.size();
  }
}
class Point {
  public double x, y, z;
  public Circle circle;
  public color c;
  public Point(double x, double y) {
    this.x = x; 
    this.y = y;
    z = 0;
    circle = new Circle((int)x, (int)y, 3, 3);
    circle.c = color(0);
  }
  public Point(double x, double y, double z) {
    this.x = x; 
    this.y = y;
    this.z = z;
    circle = new Circle((int)x, (int)y, 3, 3);
    circle.c = color(0);
  }
  public void draw() {
    circle.draw();
  } 
}
public static double ccw(Point a, Point b, Point c) {
   return (b.x - a.x) * (c.y - a.y) - (c.x - a.x) * (b.y - a.y);
}
public boolean intersects(Point a1, Point a2, Point b1, Point b2) {
   double r = ((a1.y - b1.y) * (b2.x - b1.x) - (a1.x - b1.x) *(b2.y - b1.y)) / 
   ((a2.x - a1.x) * (b2.y - b1.y) - (a2.y - a1.y) * (b2.x - b1.x));
   double s = ((a1.y - b1.y) * (a2.x - a1.x) - (a1.x - b1.x) *(a2.y - a1.y)) / 
   ((a2.x - a1.x) * (b2.y - b1.y) - (a2.y - a1.y) * (b2.x - b1.x));
   
   return r > 0 && r < 1 && s > 0 && s < 1;
}
static double distance(Point p1, Point p2) {
  return Math.pow(Math.pow(p1.x - p2.x, 2) + Math.pow(p1.y - p2.y, 2), 0.5);
}
static float distance(float x1, float y1, float x2, float y2) {
  return pow(pow(x1 - x2, 2) + pow(y1 - y2, 2), 0.5);
}
static double nChoosek(int n, int k) {
  return fact(n) / (fact(k) * fact(n - k));
}
static final double fact(int num) {
  double i = 1;
  while (num > 0) {
    i *= num;
    num--;
  }
  return i;
}
static ArrayList<Point> ToPoints(ArrayList<MoveablePoint> points) {
  ArrayList<Point> p = new ArrayList<Point>();
  for (int i = 0; i < points.size(); i++) {
    p.add(points.get(i).toPoint());
  }
  return p;
}

static double lerp(double a, double b, double l){
 return a + (b - a) * l; 
  
}