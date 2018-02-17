final int numApproxPoints = 100;

Curve generatorCurve;
Curve trajectoryCurve;
Mesh mesh;

double[] currentCurveArgs;

Rectangle drawingArea;
Rectangle goButton;
Rectangle viewGenerator;
Rectangle viewTrajectory;
Rectangle reset;

RadioButtons operations;
RadioButtons pointManipulation;
RadioButtons addPoint;

CheckBox closeGeneratorCurve;
CheckBox closeTrajectoryCurve;

TextInput extrudeDepth;

ArrayList<MoveablePoint> generatorPoints, trajectoryPoints;

int screenWidth = 700;
int screenHeight = 400;
int lastPointSelected = 0;

boolean viewingGenerator = true;
boolean animating = false;

float x, y, z;
float eulerX, eulerY, eulerZ;
void start() {
  // Add the drawing area
  drawingArea = new Rectangle(5, 5, screenWidth - 250 - 10, screenHeight - 10);
  drawingArea.c = color(255);

  operations = new RadioButtons(new String[] {"Revolve", "Extrude", "Sweep"}, 
    drawingArea.width + 20, 20, 20, 10);
  reset = new Rectangle(drawingArea.width + 20, 20, 100, 30);
  reset.c = color(255);

  closeGeneratorCurve = new CheckBox(screenWidth - 250, 140, 20);

  closeTrajectoryCurve = new CheckBox(screenWidth - 250, 170, 20);
  extrudeDepth = new TextInput(screenWidth - 250, 100, 100, 30);

  viewGenerator = new Rectangle(screenWidth - 250, 100, 100, 30);
  viewGenerator.c = color(255);
  viewTrajectory = new Rectangle(screenWidth - 140, 100, 100, 30);
  viewTrajectory.c = color(255);

  goButton = new Rectangle(screenWidth - 250, 200, 60, 30);
  goButton.c = color(255);


  // Add 2 random points to the drawing area
  generatorPoints = new ArrayList<MoveablePoint>();
  trajectoryPoints = new ArrayList<MoveablePoint>();
  for (int i = 0; i < 2; i++) {
    generatorPoints.add(new MoveablePoint((int)random(drawingArea.width), (int)random(drawingArea.height), drawingArea));
    trajectoryPoints.add(new MoveablePoint((int)random(drawingArea.width), (int)random(drawingArea.height), drawingArea));
  }
  // Add the radio buttons
  pointManipulation = new RadioButtons(new String[] {"Add point", "Delete point", "Select point"}, 
    drawingArea.width + 20, 250, 10, 10);
  addPoint = new RadioButtons(new String[] {"Add point before selected", "Add point after selected"}, 
    drawingArea.width + 20, 320, 10, 10);

  // Create a Bezier curve
  generatorCurve = new BezierCurve();
  trajectoryCurve = new BezierCurve();
  generatorCurve.controlPoints = ToPoints(generatorPoints);
  trajectoryCurve.controlPoints = ToPoints(trajectoryPoints);

  currentCurveArgs = new double[]{numApproxPoints, 100};

  generatorCurve.approximateCurve(currentCurveArgs);
  trajectoryCurve.approximateCurve(currentCurveArgs);
}

void setup() {
  size(700, 400, P3D);
  noSmooth();
  background(0);
}

void mousePressed() {
  if (mesh != null) {
    CheckReset();
  } else {
    operations.mousePressed();
    pointManipulation.mousePressed();
    // These buttons can only be pressed if adding a point is selected
    if (pointManipulation.selectedIndex == 0) {
      addPoint.mousePressed();
    }

    CheckPointsClicked();
    CheckAddPoint();
    CheckGo();
    CheckGeneratorClosed();
    if (operations.selectedIndex == 1) {
      extrudeDepth.mousePressed();
    } else if (operations.selectedIndex == 2) {
      CheckTrajectoryClosed(); 
      CheckViewGenerator();
      CheckViewTrajectory();
    }
  }
}
void mouseDragged() {
  boolean changed = false;

  for (int i = 0; i < generatorPoints.size(); i++) {
    double oldx = generatorPoints.get(i).x;
    double oldy = generatorPoints.get(i).y;
    generatorPoints.get(i).mouseDragged();
    if (oldx != generatorPoints.get(i).x || oldy != generatorPoints.get(i).y) changed = true;
  }
  generatorCurve.controlPoints = ToPoints(generatorPoints);
  if (changed)
    generatorCurve.approximateCurve(currentCurveArgs);
}

void mouseReleased() {
  for (int i = 0; i < generatorPoints.size(); i++) {
    generatorPoints.get(i).mouseReleased();
  }
}

void draw() {
  lights();
  background(0);
  if (mesh == null) {
    fill(255);
    operations.draw();
    textSize(16);
    fill(255);
    noStroke();
    text("Close generator wire", screenWidth - 220, 157);
    textSize(12);  
    stroke(255);
    pointManipulation.draw();
    textSize(16);
    goButton.draw();
    fill(0);
    stroke(100);
    textSize(30);
    text("Go", screenWidth - 250 + 9, 230);
    if (pointManipulation.selectedIndex == 0)
      addPoint.draw();

    if (operations.selectedIndex == 1) {
      extrudeDepth.draw();
      fill(255);
      textSize(16);
      text("Length to extrude", screenWidth - 150, 122);
      fill(255);
    } else if (operations.selectedIndex == 2) {
      noStroke();
      closeTrajectoryCurve.draw();
      fill(255);
      textSize(16);  
      noStroke();
      text("Close trajectory wire", screenWidth - 220, 187);    
      viewGenerator.draw();
      fill(0);
      textSize(13);
      text("View generator", screenWidth - 250 + 4, 120);
      viewTrajectory.draw();
      fill(0);
      textSize(13);
      text("View trajectory", screenWidth - 140 + 4, 120);
    }
  } else {
    reset.draw();
    fill(0);
    textSize(28);
    text("Reset", drawingArea.width + 20 + 10, 45);
  }
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
    closeGeneratorCurve.draw();
    for (int i = 0; i < generatorPoints.size(); i++) {
      if (lastPointSelected == i) {
        noStroke();
        fill(0, 255, 0);
        ellipse(generatorPoints.get(i).circle.x, generatorPoints.get(i).circle.y, 
          generatorPoints.get(i).circle.width + 4, generatorPoints.get(i).circle.height + 4);
      }
      noStroke();
      generatorPoints.get(i).draw();    
      stroke(0, 0, 255);
      fill(0, 0, 255);
      text(i+1, (int)generatorPoints.get(i).x, (int)generatorPoints.get(i).y + 20);
    }
    stroke(130, 170, 0);
    generatorCurve.draw();
  }
  popMatrix();
}



void CheckPointsClicked() {
  for (int i = 0; i < generatorPoints.size(); i++) {
    // See if they select a point and hold id
    if (pointManipulation.selectedIndex == 2) {
      generatorPoints.get(i).mousePressed();   
      if (generatorPoints.get(i).holding) lastPointSelected = i;
    }
    if (generatorPoints.get(i).holding) return;
    // See if they delete a point
    if (pointManipulation.selectedIndex == 1 && generatorPoints.get(i).circle.contains(mouseX, mouseY)) {
      generatorPoints.remove(i);
      generatorCurve.controlPoints = ToPoints(generatorPoints);
      generatorCurve.approximateCurve(currentCurveArgs);
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
    if (generatorPoints.size() == 0) index = 0;
    generatorPoints.add(index, new MoveablePoint(mouseX, mouseY, drawingArea));
    generatorCurve.controlPoints = ToPoints(generatorPoints);
    generatorCurve.approximateCurve(currentCurveArgs);
  }
}

void CheckGeneratorClosed() {
  boolean before = closeGeneratorCurve.checked; 
  closeGeneratorCurve.mousePressed(); 
  if (before != closeGeneratorCurve.checked) {
    generatorCurve.closed = closeGeneratorCurve.checked;
    generatorCurve.controlPoints = ToPoints(generatorPoints);
    generatorCurve.approximateCurve(currentCurveArgs);
  }
}
void CheckTrajectoryClosed() {
  boolean before = closeTrajectoryCurve.checked; 
  closeTrajectoryCurve.mousePressed(); 
  if (before != closeTrajectoryCurve.checked) {
    trajectoryCurve.closed = closeTrajectoryCurve.checked;
    trajectoryCurve.controlPoints = ToPoints(trajectoryPoints);
    trajectoryCurve.approximateCurve(currentCurveArgs);
  }
}
void CheckGo() {
  if (goButton.contains(mouseX, mouseY)) {
    if (operations.selectedIndex == 0) {
      currentCurveArgs[0] = 100;
      currentCurveArgs[1] = 100;
      mesh = ((BezierCurve)(generatorCurve)).approximateRevolution(currentCurveArgs, 'x');
      mesh.GenerateASCIIFile();
    } else if (operations.selectedIndex == 1) {
      currentCurveArgs[0] = 100;
      currentCurveArgs[1] = 100;
      mesh = ((BezierCurve)(generatorCurve)).extrude(currentCurveArgs, 
        Integer.parseInt(extrudeDepth.text));
      mesh.GenerateASCIIFile();
    } else if (operations.selectedIndex == 2) {
    }
  }
}
void CheckReset() {
  if (reset.contains(mouseX, mouseY)) {
    mesh = null;
    x = y = z = eulerX = eulerY = eulerZ = 0;
  }
}
void keyPressed() {
  if (mesh == null) { 
    if (operations.selectedIndex == 1) {
      extrudeDepth.keyPressed();
    }
  } else {
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
}
void CheckViewGenerator() {
}
void CheckViewTrajectory() {
}