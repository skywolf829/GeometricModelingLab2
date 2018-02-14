final int numApproxPoints = 100;

String[] CurveOptions = {"Bezier Curve", 
  "B-Spline", 
  "Subdivision Curve", 
  "Subdivision Quadratic B-Spline"
};

Curve curve;
Mesh mesh;
double[] currentCurveArgs;

Rectangle reset;
Rectangle drawingArea;
Rectangle doRevolution;
Rectangle doExtrude;
Rectangle doSweep;
Rectangle closeCurve;

RadioButtons pointManipulation;
RadioButtons addPoint;

CheckBox closed;

TextInput extrudeDepth;

ArrayList<MoveablePoint> points;

int screenWidth = 700;
int screenHeight = 400;
int lastPointSelected = 0;

float x, y, z;
float eulerX, eulerY, eulerZ;
void start() {
  // Add the drawing area
  drawingArea = new Rectangle(5, 5, screenWidth - 250 - 10, screenHeight - 10);
  drawingArea.c = color(255);

  doRevolution = new Rectangle(screenWidth - 250, 50, 60, 30);
  doRevolution.c = color(255);

  closed = new CheckBox(screenWidth - 250, 20, 20);

  // Add 2 random points to the drawing area
  points = new ArrayList<MoveablePoint>();
  for (int i = 0; i < 2; i++) {
    points.add(new MoveablePoint((int)random(drawingArea.width), (int)random(drawingArea.height), drawingArea));
  }
  // Add the radio buttons
  pointManipulation = new RadioButtons(new String[] {"Add point", "Delete point", "Select point"}, 
    drawingArea.width + 20, 250, 10, 10);
  addPoint = new RadioButtons(new String[] {"Add point before selected", "Add point after selected"}, 
    drawingArea.width + 20, 320, 10, 10);

  // Create a Bezier curve
  curve = new BezierCurve();
  curve.controlPoints = ToPoints(points);
  currentCurveArgs = new double[]{numApproxPoints, 4};
  curve.approximateCurve(currentCurveArgs);
}

void setup() {
  size(700, 400, P3D);
  noSmooth();
  background(0);
}

void mousePressed() {
  pointManipulation.mousePressed();
  // These buttons can only be pressed if adding a point is selected
  if (pointManipulation.selectedIndex == 0) {
    addPoint.mousePressed();
  }

  CheckPointsClicked();
  CheckAddPoint();
  CheckDoRevolve();
  CheckClosed();
}
void mouseDragged() {
  boolean changed = false;

  for (int i = 0; i < points.size(); i++) {
    double oldx = points.get(i).x;
    double oldy = points.get(i).y;
    points.get(i).mouseDragged();
    if (oldx != points.get(i).x || oldy != points.get(i).y) changed = true;
  }
  curve.controlPoints = ToPoints(points);
  if (changed)
    curve.approximateCurve(currentCurveArgs);
}

void mouseReleased() {
  for (int i = 0; i < points.size(); i++) {
    points.get(i).mouseReleased();
  }
}

void draw() {
  lights();
  background(0);
  closed.draw();
  fill(255);
  textSize(16);
  text("Close curve", screenWidth - 220, 37);
  textSize(12);  
  stroke(255);
  pointManipulation.draw();
  textSize(16);
  doRevolution.draw();
  fill(0);
  stroke(100);
  text("Revolve", screenWidth - 250, 72);
  if (pointManipulation.selectedIndex == 0)
    addPoint.draw();

  pushMatrix();
  rotateY(eulerY);
  rotateX(eulerX);
  rotateZ(eulerZ);
  translate(x, y, z);

  stroke(255, 0, 0);
  line(-1000, 0, 0, 1000, 0, 0);
  stroke(0, 255, 0);
  line(0, -1000, 0, 0, 1000, 0);
  stroke(0, 0, 255);
  line(0, 0, -1000, 0, 0, 1000);

  if (mesh != null) {
    stroke(255);
    mesh.draw();
  } else {
    for (int i = 0; i < points.size(); i++) {
      if (lastPointSelected == i) {
        noStroke();
        fill(0, 255, 0);
        ellipse(points.get(i).circle.x, points.get(i).circle.y, 
          points.get(i).circle.width + 4, points.get(i).circle.height + 4);
      }
      noStroke();
      points.get(i).draw();    
      stroke(0, 0, 255);
      fill(0, 0, 255);
      text(i+1, (int)points.get(i).x, (int)points.get(i).y + 20);
    }
    stroke(130, 170, 0);
    curve.draw();
  }
  popMatrix();
}



void CheckPointsClicked() {
  for (int i = 0; i < points.size(); i++) {
    // See if they select a point and hold id
    if (pointManipulation.selectedIndex == 2) {
      points.get(i).mousePressed();   
      if (points.get(i).holding) lastPointSelected = i;
    }
    if (points.get(i).holding) return;
    // See if they delete a point
    if (pointManipulation.selectedIndex == 1 && points.get(i).circle.contains(mouseX, mouseY)) {
      points.remove(i);
      curve.controlPoints = ToPoints(points);
      curve.approximateCurve(currentCurveArgs);
      return;
    }
  }
}

void CheckAddPoint() {
  // See if we add a point
  if (pointManipulation.selectedIndex == 0 && drawingArea.contains(mouseX, mouseY)) {
    int index = 0;
    if (addPoint.selectedIndex == 0) index = lastPointSelected;
    else index = lastPointSelected+1;
    if (points.size() == 0) index = 0;
    points.add(index, new MoveablePoint(mouseX, mouseY, drawingArea));
    curve.controlPoints = ToPoints(points);
    curve.approximateCurve(currentCurveArgs);
  }
}

void CheckClosed() {
  boolean before = closed.checked; 
  closed.mousePressed(); 
  if (before != closed.checked) {
    curve.closed = closed.checked;
    curve.approximateCurve(currentCurveArgs);
  }
}
void CheckDoRevolve() {
  if (doRevolution.contains(mouseX, mouseY)) {
    currentCurveArgs[0] = 100;
    currentCurveArgs[1] = 100;
    mesh = ((BezierCurve)(curve)).approximateRevolution(currentCurveArgs, 'x');
    mesh.GenerateASCIIFile();
  }
}

void keyPressed() {

  if (key == 'w') {
    y+=25;
  }
  if (key =='s') {
    y-=25;
  }
  if (key == 'a') {
    x+=25;
  }
  if (key =='d') {
    x-=25;
  }
  if (key == 'q') {
    z-=25;
  }
  if (key =='e') {
    z+=25;
  }


  if (key == '1') {
    eulerX+=25;
  }
  if (key =='2') {
    eulerX-=25;
  }
  if (key == '3') {
    eulerY+=25;
  }
  if (key =='4') {
    eulerY-=25;
  }
  if (key == '5') {
    eulerZ-=25;
  }
  if (key =='6') {
    eulerZ+=25;
  }
}