class disk {
  
  //velocity, center point, and radius
  vec velocity;
  pt center;
  float radius;
  
  disk(vec v, pt c, float r) {
    velocity = v;
    center = c;
    radius = r; 
  }
  
  void drawDisk1() {
    stroke(red);
    ellipse(center.x, center.y, radius*2.0, radius*2.0);
    noStroke();
  }
  
  void drawDisk2() {
    stroke(blue);
    ellipse(center.x, center.y, radius*2.0, radius*2.0);
    noStroke();
  }
  
  void drawCollisionDisk(float t) {
    stroke(green);
    ellipse(center.x + (t * (velocity.x)), center.y + (t * (velocity.y)), radius*2.0, radius*2.0);
    noStroke();
  }
  
  void drawAnimationDisk(float t) {
    stroke(grey);
    ellipse(center.x + (t * (velocity.x)), center.y + (t * (velocity.y)), radius*2.0, radius*2.0);
    noStroke();    
  }
  
  boolean checkForCollison(disk d) {
    if ( dist(center.x, center.y, d.center.x, d.center.y) <= (radius + d.radius)) {
      return true;
    }
    else return false; 
  }
  
//  void drawDisk1(disk d) {
//    stroke(red);
//    ellipse(d.center.x, d.center.y, d.radius, d.radius);
//    noStroke();
//  }
//  
//  
//  //Shit's broke
//  void drawDisk(disk d, color clr) {
//    stroke(clr);
//    ellipse(d.center.x, d.center.y, d.radius, d.radius);
//    noStroke();
//    
//  }
  
}
