

class IntSlider {
  int min, max, x, y, size;
  String name;
  Rectangle background;
  Rectangle slider; 
  boolean holding = false;
  int sliderSize;
  public IntSlider(String name, int min, int max, int x, int y, int size) {
    this.min = min;
    this.max = max;
    this.name = name;
    this.x = x;
    this.y = y; 
    this.size = size;
    sliderSize = size / 15;
    background = new Rectangle(x, y, size, sliderSize);
    slider = new Rectangle(x, y - 5, sliderSize / 2, sliderSize + 10);
    slider.c = color(0);
    background.c = color(0);
  }
  public void setMin(int n) {
    min = n;
  }
  public void setMax(int n) {
    max = n;
  }
  public int getValue() {
    int closest = 0;
    float dist = distance(x, y, slider.x, slider.y);
    for (int i = 1; i <= max - min; i += 1) {
      float d = distance(slider.x, slider.y, x + i * (size / (max - min)), y);
      if (dist > d) {
        dist =  d;
        closest = i;
      }
    }
    return min + closest;
  }
  public void draw() {

    background.draw();
    slider.draw();
    fill(255);
    textSize(size / 20);
    text(min, x - sliderSize * (min + "").length() - 5, y + sliderSize);
    text(max, x + size + 5, y + sliderSize);
    text(getValue(), slider.x, slider.y + slider.height + sliderSize);
  }

  public void mousePressed() {
    if (slider.contains(mouseX, mouseY)) {
      holding = true;
    }
  }
  public void mouseDragged() {
    if (holding) {
      slider.x = mouseX;
      if (slider.x < x) slider.x = x;
      if (slider.x > x + size) slider.x = x + size;
    }
  }
  public void mouseReleased() {
    holding = false;
  }
}

class MoveablePoint extends Point {
  public Circle circle;
  public boolean holding = false;
  public Rectangle bounds;
  public MoveablePoint(int x, int y, Rectangle bounds) {
    super(x, y);
    this.x = x;
    this.y = y;
    circle = new Circle(x, y, 20, 20);
    circle.c = color(0, 0, 255);
    this.bounds = bounds;
  }
  public MoveablePoint(int x, int y, int z, Rectangle bounds) {
    super(x, y, z);
    this.x = x;
    this.y = y;
    this.z = z;
    circle = new Circle(x, y, 20, 20);
    circle.c = color(0, 0, 255);
    this.bounds = bounds;
  }
  public Point toPoint() {
    return new Point(x, y);
  }
  public void draw() {
    circle.c = color(0, 0, 255);
    if (holding) circle.c = color(255, 0, 0);
    circle.draw();
  }
  public void mousePressed() {
    if (circle.contains(mouseX, mouseY)) {
      holding = true;
    }
  }
  public void mouseDragged() {
    if (holding) {
      x = mouseX;
      y = mouseY;
      circle.x = mouseX;
      circle.y = mouseY;
      if (circle.x < bounds.x) {
        circle.x = bounds.x;
        x = bounds.x;
      }
      if (circle.y < bounds.y) {
        circle.y = bounds.y;
        y = bounds.y;
      }
      if (circle.x > bounds.x + bounds.width) {
        circle.x = bounds.x + bounds.width;
        x = bounds.x + bounds.width;
      }
      if (circle.y > bounds.y + bounds.height) {
        circle.y = bounds.y + bounds.height;
        y = bounds.y + bounds.height;
      }
    }
  }
  public void mouseReleased() {
    holding = false;
  }
}

class Rectangle {
  public int x, y, width, height;
  public color c;
  public Rectangle(int x, int y, int width, int height) {
    this.x = x;
    this.y = y;
    this.width = width;
    this.height = height;
  }
  public void draw() {
    fill(c);
    rect(x, y, width, height);
  }
  boolean contains(float x, float y) {
    return x >= this.x && x <= this.x + width && y >= this.y && y <= this.y + height;
  }
}

class Circle {
  public int x, y, width, height;
  public color c;
  public Circle(int x, int y, int width, int height) {
    this.x = x;
    this.y = y;
    this.width = width;
    this.height = height;
  }
  boolean contains(float x, float y) {
    return x >= this.x - width / 2.0f && x <= this.x + width / 2.0f && 
      y >= this.y - height / 2.0f && y <= this.y + height / 2.0f;
  }
  public void draw() {
    fill(c);
    ellipse(x, y, width, height);
  }
}

class RadioButton {
  public boolean selected = false;
  public Circle c;
  public String name;
  public RadioButton(String n, int x, int y, int width, int height) {
    c = new Circle(x, y, width, height);
    c.c = color(255);
    this.name = n;
  }

  public void draw() {
    c.draw();  
    textSize(c.height);
    text(name, c.x + c.width, c.y + c.height / 2.0f);  
    if (selected) {
      fill(0);
      ellipse(c.x, c.y, c.width - 2, c.height - 2);
    }
  }
}

class RectangleButton {
  public Rectangle r;
  public String name;
  public RectangleButton(String n, int x, int y, int width, int height) {
    r = new Rectangle(x, y, width, height);
    this.name = n;
    r.c = color(200);
  }
  public void draw() {
    r.draw();
    fill(255);
    textSize(r.height - 4);
    text(name, r.x, r.y + r.height / 2.0f + 10);
  }
}

class RadioButtons {
  ArrayList<RadioButton> buttons;
  public String[] options;
  public int x, y, height, spacing;
  public int selectedIndex = 0;
  public RadioButtons(String[] options, int x, int y, int height, int spacing) {
    buttons = new ArrayList<RadioButton>();
    this.options = options;
    this.x = x;
    this.y = y;
    this.height = height;
    this.spacing = spacing;

    for (int i = 0; i < options.length; i++) {
      buttons.add(new RadioButton(options[i], x, y + i * (height + spacing), height, height));
    }
    buttons.get(0).selected = true;
  }
  public int getHeight() {
    return buttons.size() * (height + spacing);
  }
  public void mousePressed() {
    boolean clickHandled = false;
    int clickedButton = -1;
    for (int i = 0; i < buttons.size(); i++) {
      if (buttons.get(i).c.contains(mouseX, mouseY)) {
        buttons.get(i).selected = true;
        clickHandled = true;
        selectedIndex = i;
        clickedButton = i;
      }
    }
    if (clickHandled) {
      for (int i = 0; i < buttons.size(); i++) {
        if (clickedButton != i) {
          buttons.get(i).selected = false;
        }
      }
    }
  }

  public void draw() {
    for (int i = 0; i < buttons.size(); i++) {
      buttons.get(i).draw();
    }
  }
}

class TextInput {
  public boolean selected = false;
  public String text = "0"; 
  public Rectangle r;
  public TextInput(int x, int y, int width, int height) {
    r = new Rectangle(x, y, width, height);
    r.c = color(255);
  }
  public void draw() {
    noStroke();
    r.draw(); 
    fill(0);
    textSize(r.height - 5);
    text(text, r.x + 1, r.y + r.height);
    if (selected) {
      noFill();
      stroke(0, 255, 0);
      rect(r.x, r.y, r.width, r.height);
    } else {
      noFill();
      stroke(0);
      rect(r.x, r.y, r.width, r.height);
    }
  }
  public void mousePressed() {
    if (r.contains(mouseX, mouseY)) {
      selected = true;
    } else selected = false;
  }
  void keyPressed() {
    if (selected) {
      if (keyCode == BACKSPACE) {
        if (text.length() > 0) {
          text = text.substring(0, text.length()-1);
        }
      } else if (keyCode == DELETE) {
        text = "";
      } else if (keyCode != SHIFT && keyCode != CONTROL && keyCode != ALT
        && textWidth(text + key) < r.width) {
        text = text + key;
      }
    }
  }
}

public class CheckBox{
  public boolean checked = false;
  int x, y, w;
  Rectangle r;
  public CheckBox(int x, int y, int w){
    this.x = x;
    this.y = y;
    this.w = w;
    r = new Rectangle(x, y, w, w);
    r.c = color(155, 155, 155);
  }
  void mousePressed(){
    if(r.contains(mouseX, mouseY)){
     checked = !checked; 
    }
  }
  void draw(){
   r.draw();
   textSize(w+5);
   stroke(255, 0, 0);
   fill(255, 0, 0);
   if(checked){
     text("X",x+2, y + w);
   }
  }
}