// LecturesInGraphics: 
// Points-base source for project 05
// Steady patterns of strokes
// Template provided by Prof Jarek ROSSIGNAC
// Modified by student:  Ryan Mendes

//**************************** global variables ****************************
pts P = new pts(); // Guide points
pts S = new pts(); // points of stroke
int[] lineLengths = { 5, 4, 5, 4 };
float t=0, f=0;
boolean animate=false, showStrokes=true, showPoints = true;

//STUFF I ADDED
disk disk1, disk2; //Disks
vec v1, v2; //Vectors
float r1, r2; //Radii

disk pDisk1, pDisk2; //Disks that are drawn when collision is predicted
vec vBC, vDV; //Vector Between Centers and Velocity Difference Vector
float dpC; //Dot product of centers
boolean foundT = false; //Use this to see if a valid t has been calculated

disk aDisk, bDisk; //Use these for the animations
vec postV1, postV2; //New velocities post-collision
vec unitT; //The vector between the center of the circles at time of collision, to be normalized
vec normalVT; //Normal vector at time of collision t
pt postC1, postC2; //Centers of disks post-collision, and the point of collision of the circles
float m1, m2; //Masses
float mr1, mr2; //Mass ratios that are used as weights for computing the velocities post-collision
float pi = 3.14159265359; //Since Math.Pi doesn't want to work

float animator = 0.0; //Use this as a timer for the animations
float timeStep; //This is the amount time is incremented, for the animation
float tInc1 = 0.1; //And these are values that are set up...
float tInc2 = 0.01; //...so that we can easily switch between them with a hotkey
boolean colHasHappened = false; //boolean to avoid drawing the overshoot


//**************************** initialization ****************************
void setup() {               // executed once at the begining 
  size(600, 600);            // window size
  frameRate(30);             // render 30 frames per second
  smooth();                  // turn on antialiasing
  myFace = loadImage("data/pleaseRes.png");  // load image from file pic.jpg in folder data *** replace that file with your pic of your own face
  P.declare().resetOnCircle(6); //   P.declare().resetOnCircle(14);
  S.declare();
  
  pt TL = P(width/5, height/5);
  pt BR = P(4*width/5, 4*height/5);

  for (int i = 0; i < 5; i++) {
     linePoint(P, 0, i).setTo(P(TL.x, L(TL.y, BR.y, i/4f)));
     linePoint(P, 2, i).setTo(P(BR.x, L(TL.y, BR.y, i/4f)));
  }
  for (int i = 0; i < 4; i++) {
     linePoint(P, 1, i).setTo(P(L(TL.x, BR.x, i/3f), TL.y));
     linePoint(P, 3, i).setTo(P(L(TL.x, BR.x, i/3f), BR.y));
  }
  
  //********************************************************************
  //********************************************************************
  //********************************************************************
  
  //Initializing the timeStep, to be used later in animation
    timeStep = tInc1;

  //Hardcoding the points initial positions
    P.empty();
    P.addPt(100,400);
    P.addPt(100,350);
    P.addPt(150, 400);
    P.addPt(500,400);
    P.addPt(500,300);
    P.addPt(400,400);
    
  //Creating the disks
    //Disc 1
    v1 = new vec (P.G[1].x - P.G[0].x, P.G[1].y - P.G[0].y);
    r1 = (dist(P.G[2].x, P.G[2].y, P.G[0].x, P.G[0].y));    
    disk1 = new disk(v1, P.G[0], r1);
    disk1.drawDisk1();
    //Disc 2
    v2 = new vec (P.G[4].x - P.G[3].x, P.G[4].y - P.G[3].y);
    r2 = (dist(P.G[5].x, P.G[5].y, P.G[3].x, P.G[3].y));
    disk2 = new disk(v2, P.G[3], r2);
    disk2.drawDisk2();
    
  //********************************************************************
  //********************************************************************
  //********************************************************************    
}

/**
 * Draws the line with the given index (0-3).
 * @param P - storage pts object
 * @param index - point index value 0-4
 * */
void drawPolyline(pts P, int line) {
  for (int i = 0; i < lineLengths[line]-1; i++) {
    edge(linePoint(P, line, i), linePoint(P, line, i+1));
  }
}

float L(float a, float b, float s) { return a*(1-s) + b*s; }

/**
 * Returns the point on line (line) at index (index).
 * @param P - storage pts object
 * @param line - line index value 0-4
 * @param index - point index value 0-4 or 0-5
 * */
pt linePoint(pts P, int line, int index) {
  if (line == 0) index = 4 - index;
  else if (line == 3) index = 3 - index;
  
  for (int i = 0; i < line; i++) 
    index += lineLengths[i]-1; // -1 because it wraps
  return P.G[index % P.nv];
}

//**************************** display current frame ****************************
void draw() {      // executed at each frame
  background(white); // clear screen and paints white background
  
  //********************************************************************
  //********************************************************************
  //******************************************************************** 
  
  if (!animate) animator = 0.0;
  
  //Update the velocities
  v1 = new vec (P.G[1].x - P.G[0].x, P.G[1].y - P.G[0].y);
  v2 = new vec (P.G[4].x - P.G[3].x, P.G[4].y - P.G[3].y);
  disk1.velocity = v1;
  disk2.velocity = v2;
  
  //Update the radii
  r1 = (dist(P.G[2].x, P.G[2].y, P.G[0].x, P.G[0].y));
  r2 = (dist(P.G[5].x, P.G[5].y, P.G[3].x, P.G[3].y));
  disk1.radius = r1;
  disk2.radius = r2;
  
  //Redraw the disks
  disk1.drawDisk1();
  disk2.drawDisk2();
  
  //Draw the velocity vectors
  stroke(red);
  arrow(P.G[0], P.G[1]);
  stroke(blue);
  arrow(P.G[3], P.G[4]);
  noStroke();
  
  //Draw the radii
  stroke(red);
  line(P.G[2].x, P.G[2].y, P.G[0].x, P.G[0].y);
  stroke(blue);
  line(P.G[3].x, P.G[3].y, P.G[5].x, P.G[5].y);
  noStroke();
  
  //System.out.println("r1: " + r1 + " r2: " + r2 + " Distance: " + dist(disk1.center.x, disk1.center.y, disk2.center.x, disk2.center.y) + " Collision: " + disk1.checkForCollison(disk2));
  
  //Do the collision detection ********************************
  
  vBC = new vec(P.G[3].x - P.G[0].x, P.G[3].y - P.G[0].y); //Vector between centers
  vDV = new vec(v2.x - v1.x, v2.y - v1.y); //vector difference vector
  
  //Variables used for the quadratic formula
  float a = dot(vDV, vDV);
  float b = 2.0 * (dot(vBC, vDV));
  float c = dot(vBC, vBC) - sq(r1+r2);
  float discrim = (b*b) - (4*(a*c));
  
  if (discrim >= 0) { //Ensure the roots we are getting are real solutions
    //Find the additive quadratic root
    float plusRoot = ((-b) + sqrt(discrim))/(2*a);
    //Find the subtractive quadratic root
    float minusRoot = ((-b) - sqrt(discrim))/(2*a);
    //Pick the smallest positive root
      if ((plusRoot < minusRoot && plusRoot >= 0) || (minusRoot < 0 && plusRoot > 0)) {
        t = plusRoot;
        foundT = true;
      }
      else if (minusRoot < plusRoot && minusRoot >= 0 || (plusRoot < 0 && minusRoot > 0)) {
        t = minusRoot;
        foundT = true;
      }
      else foundT = false;
      
      if (foundT) { //if there's a valid collision
        if (t >= 0) { //(t >= 0 && t <= 1) previously
        
          //Draw the circles at time of collision
          disk1.drawCollisionDisk(t);
          disk2.drawCollisionDisk(t);
     
          //Find the centers at time of collision
          postC1 = new pt(disk1.center.x + (t * disk1.velocity.x), disk1.center.y + (t * disk1.velocity.y));
          postC2 = new pt(disk2.center.x + (t * disk2.velocity.x), disk2.center.y + (t * disk2.velocity.y));
          
          //Find the vector along the line connecting the centers at time of collison t
          unitT = new vec (postC2.x - postC1.x, postC2.y - postC1.y);  //Get the vector
          stroke(magenta);
          show(postC1, unitT);
          noStroke();
          //...and normalize it
          unitT = U(unitT); //Equivalent to unitT.normalize();
          
          //Compute the normal vector at collision time t;
          normalVT = new vec( unitT.x * dot(vDV, unitT), unitT.y * dot(vDV, unitT));

          //Compute the masses
          m1 = sq(pi * r1);
          m2 = sq(pi * r2); 

          //Compute the mass ratios
          mr1 = m2/((m2+m1)/2);
          mr2 = m1/((m2+m1)/2);
          
          //Compute the velocities post-collision
          postV1 = new vec(disk1.velocity.x + mr1 * normalVT.x, disk1.velocity.y + mr1 * normalVT.y);
          postV2 = new vec(disk2.velocity.x + mr2 * -normalVT.x, disk2.velocity.y + mr2 * -normalVT.y);
          stroke(cyan);
          arrow(postC1, postV1);
          arrow(postC2, postV2);
          noStroke();
          
          //Creating disks to store values for post-collision animation
          aDisk = new disk(postV1, postC1, r1);
          bDisk = new disk(postV2, postC2, r2); 
          
          //Animate the circles before and after collision, using t as the predicted instant of collision
          if (animate) {
            if (animator + timeStep >= t) { //If the next frame will be post-collision
              if (colHasHappened == false) {
                disk1.drawAnimationDisk(t);
                disk2.drawAnimationDisk(t);
                colHasHappened = true;                
              }
              else {
                float newT = animator - t;
                aDisk.drawAnimationDisk(newT);
                bDisk.drawAnimationDisk(newT);                 
              }   
            }
            else {
              disk1.drawAnimationDisk(animator);
              disk2.drawAnimationDisk(animator);
            }
            animator += timeStep;
            foundT = false;
            if (animator >= 5.0) {
              animator = 0.0;
              colHasHappened = false;
            }          
          } //End of if (animate)
        }
      } //End of if (foundT)
     

      System.out.println("plusRoot = " + plusRoot + " minusRoot = " + minusRoot + " Collision : " + disk1.checkForCollison(disk2) + " t: " + t + " timeStep: " + timeStep + " animate: " + animate);
      
  }//End of if (discrim > 0)
  
  //Handle the animation if a time of collision is never found
  else if (!foundT) {
    if (animate) {
      disk1.drawAnimationDisk(animator);
      disk2.drawAnimationDisk(animator); 
      animator += timeStep;
        if (animator >= 5.0) {
          animator = 0.0;
        }   
    }       
  }
  


  //********************************************************************
  //********************************************************************
  //********************************************************************

  // Draw strokes
  int[] colors = { 
    red, black, green, blue
  };
//  if (jarekLines) { // ADDED
//    for (int i = 0; i < lineLengths.length; i++) {
//      pen(colors[i%colors.length], 2);
//      drawPolyline(P, i);
//    }
//  }//end of if(jarekLines)

  // Draw points
//  if (showPoints) {
//    pen(black, 1);
//    int R = 15;
//    for (int i = 0; i < P.nv; i++) {
//      fill(white);
//      show(P.G[i], R);
//      fill(black);
//      label(P.G[i], String.valueOf((char)('A'+i)));
//    }

    // Draw color-coded indices
    //vec offset = V(-R*2, 0);
//    for (int line = 0; line < 4; line++) {
//      fill(colors[(line%colors.length)]);
//      pt M = P(0, 0);
//      for (int i = 0; i < 4; i++) {
//        pt p = linePoint(P, line, i);
//        M.add(p);
//        label(P(p, offset), String.valueOf(i));
//      }
//      M.scale(0.25f);
//      label(P(M, S(2.5f, offset)), "Line " + line); 
//      offset = R(offset);
//    }
  //}

//  if (showStrokes) {
//    noFill(); 
//    stroke(blue); 
//    S.drawCurve();
//  } 

  displayHeader();
  if (scribeText && !filming) displayFooter(); // shows title, menu, and my face & name 
  if (filming && (animating || change)) saveFrame("FRAMES/F"+nf(frameCounter++, 4)+".tif");  
  change=false; // to avoid capturing frames when nothing happens
}  // end of draw()

//**************************** user actions ****************************
void keyPressed() { // executed each time a key is pressed: sets the "keyPressed" and "key" state variables, 
  // till it is released or another key is pressed or released
  if (key=='?') scribeText=!scribeText; // toggle display of help text and authors picture
  if (key=='!') snapPicture(); // make a picture of the canvas
  if (key=='~') { 
    filming=!filming;
  } // filming on/off capture frames into folder FRAMES
  //if (key=='s') P.savePts("data/pts");   
  if (key=='l') P.loadPts("data/pts"); 
  if (key=='p') showPoints = !showPoints;
  if (key=='S') showStrokes=!showStrokes;   // quit application
  if (key=='Q') exit();  // quit application
  change=true;
  //Below here are ADDED by me
  if (key=='a') animate = !animate;
  if (key=='t') {
    if (timeStep == tInc1) {
      timeStep = tInc2;
    }
    else if (timeStep == tInc2) {
      timeStep = tInc1;
    }   
  }
 
}

void mousePressed() {  // executed when the mouse is pressed
  if (keyPressed && key==' ') S.empty();
  if (!keyPressed) P.pickClosest(Mouse()); // used to pick the closest vertex of C to the mouse
  change=true;
}

void mouseDragged() {
  //if (!keyPressed || (key=='a')) P.dragPicked();   // drag selected point with mouse
  //Rewriting Jarek's function so that I can move the circles if the center point is dragged
  if (!keyPressed || (key=='a')) { //ADDED
    
    if (P.pv == 0) {
      P.G[0].moveWithMouse();
      P.G[1].moveWithMouse();
      P.G[2].moveWithMouse(); 
    }
    else if (P.pv == 3) {
      P.G[3].moveWithMouse();
      P.G[4].moveWithMouse();
      P.G[5].moveWithMouse(); 
    }
   else
     P.dragPicked();   // drag selected point with mouse 
   
  } 
  if (keyPressed) {
    if (key=='.') f+=2.*float(mouseX-pmouseX)/width;  // adjust current frame   
    if (key=='t') {
      P.dragAll();
      S.dragAll();
    } // move all vertices
    if (key=='r') {
      P.rotateAll(ScreenCenter(), Mouse(), Pmouse());
      S.rotateAll(ScreenCenter(), Mouse(), Pmouse());
    } // turn all vertices around their center of mass
    if (key=='z') {
      P.scaleAll(ScreenCenter(), Mouse(), Pmouse()); 
      S.scaleAll(ScreenCenter(), Mouse(), Pmouse());
    } // scale all vertices with respect to their center of mass
    if (key==' ') S.addPt(Mouse());
  }
  change=true;
}  

//**************************** text for name, title and help  ****************************
String title ="Project 6: Collision Detection and Elastic Shock", 
name ="CS3451 Fall 2014  Ryan Mendes", 
menu="a: animate the disks' progression over time | t: toggle timestep speed", 
guide="Drag centers to move whole disks, or vector and radius separately"; // help info


