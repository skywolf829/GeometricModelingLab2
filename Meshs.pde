public class Mesh {
  public int x, y, z;
  public int eulerX, eulerY, eulerZ;

  ArrayList<Point> vertices;
  ArrayList<ArrayList<Integer>> ASCIIfaces;
  public int faceColor = color(0, 0, 255);

  public Mesh(ArrayList<Point> vertices, ArrayList<ArrayList<Integer>> ASCIIfaces) {
    this.vertices = vertices;
    this.ASCIIfaces = ASCIIfaces;
  }
  public void GenerateASCIIFile() {
    PrintWriter f = createWriter("Mesh.obj");
    f.println(vertices.size() + " " + ASCIIfaces.size());
    for (int i = 0; i < vertices.size(); i++) {
      f.println(vertices.get(i).x + " " + vertices.get(i).y + " " + vertices.get(i).z);
    }
    for (int i = 0; i < ASCIIfaces.size(); i++){
      f.print(ASCIIfaces.get(i).size() + " ");
      for(int j = 0; j < ASCIIfaces.get(i).size(); j++){
       f.print(ASCIIfaces.get(i).get(j) + " ");
      }
      f.println();
    }
    f.flush();
    f.close();
  }
  public void draw() {
    for (int i = 0; i < ASCIIfaces.size(); i++) {
      fill(faceColor);
      beginShape();
      Point first = vertices.get(ASCIIfaces.get(i).get(0));
      Point p1 = new Point(0, 0, 0);
      Point p2 = new Point(0, 0, 0);
      for (int j = 0; j < ASCIIfaces.get(i).size()-1; j++) {
        p1 = vertices.get(ASCIIfaces.get(i).get(j));
        p2 = vertices.get(ASCIIfaces.get(i).get(j+1));
        vertex((float)p1.x, (float)p1.y, (float)p1.z);
        line((float)p1.x, (float)p1.y, (float)p1.z, (float)p2.x, (float)p2.y, (float)p2.z);
      }
      line((float)p2.x, (float)p2.y, (float)p2.z, (float)first.x, (float)first.y, (float)first.z);
      vertex((float)first.x, (float)first.y, (float)first.z);
      endShape();
    }
  }
}