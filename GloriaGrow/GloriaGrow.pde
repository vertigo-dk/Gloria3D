// Substrate Watercolor
// j.tarbell   June, 2004
// Albuquerque, New Mexico
// complexification.net

// Processing 0085 Beta syntax update
// j.tarbell   April, 2005

int dimx = 1500;
int dimy = 1500;
int num = 0;
int maxnum = 20;
int startradius = 15; //Initial cracks grow from a circle with this radius
float cuMax = 0.2; //The max angle of curvature
float strokeRadius = 5; //Add to line thickness
boolean run = true; //Toggle if drawing is active
boolean useColors = false; //Toggle the sandpainter colors
boolean useStroke = true; //Toggle if stroke has thickness
int bgColor = 255;
int crackColor = 0;

int maxAge = 1000; //New lines spawn from points that are younger than maxAge

// color parameters
int maxpal = 512;
int numpal = 0;
color[] goodcolor = new color[maxpal];

Slider sliderStroke;
Slider sliderMaxAge;
Slider sliderCurvature;
Slider sliderMaxnum;

// grid of cracks
int[] cgrid;
float[] cugrid; //Grid of curvature
int[] tgrid; //Grid of timestamps
Crack[] cracks;

// MAIN METHODS ---------------------------------------------

void setup() {
  size(1500,1500);
  background(bgColor);
  takecolor("palette.png");
  
  cgrid = new int[dimx*dimy];
  cugrid = new float[dimx*dimy]; //data for curvature of lines
  tgrid = new int[dimx*dimy];
  cracks = new Crack[100];
  
  sliderStroke = new Slider( 50, 90, 200, 10, 0, 5, "Stroke radius");
  sliderStroke.setSliderVal(strokeRadius);
  sliderMaxAge = new Slider( 50, 140, 200, 10, 100, 10000, "Max age");
  sliderMaxAge.setSliderVal(maxAge);
  sliderCurvature = new Slider( 50, 190, 200, 10, 0, 0.5, "Curvature");
  sliderCurvature.setSliderVal(cuMax);
  sliderMaxnum = new Slider( 50, 240, 200, 10, 10, 100, "Max lines");
  sliderMaxnum.setSliderVal(maxnum);
  
  begin();
}

void draw() {
  
  if(run) {
    // crack all cracks
    for (int n=0;n<num;n++) {
      cracks[n].move();
    }
  }
  
  strokeWeight(1);
  sliderStroke.display();
  sliderMaxAge.display();
  sliderCurvature.display();
  sliderMaxnum.display();
  strokeRadius = sliderStroke.sliderVal;
  maxAge = int(sliderMaxAge.sliderVal);
  cuMax = sliderCurvature.sliderVal;
  maxnum = int(sliderMaxnum.sliderVal);
  
  fill(255);
  stroke(255);
  rect( 40, 30, 400, 40);
  fill(0);
  text("s for start/stop, i for save image, space for restart", 50, 50);
  text("c for colors, l for line stroke, t for invert colors", 50, 70);
}

void keyPressed() {
  
  switch(key) {
    case ' ':
      begin();
      break;
    case 's':
      run = !run;
      break;
    case 'i':
      saveFrame();
      break;
    case 'c':
      useColors = !useColors;
      break;
    case 'l':
      useStroke = !useStroke;
      break;
    case 't':
      if (bgColor == 255) { bgColor = 0; } else { bgColor = 255; }
      if (crackColor == 255) { crackColor = 0; } else { crackColor = 255; }
      break;
  }
}

void mouseDragged() {

  sliderStroke.checkPressed(mouseX, mouseY);
  sliderMaxAge.checkPressed(mouseX, mouseY);
  sliderCurvature.checkPressed(mouseX, mouseY);
  sliderMaxnum.checkPressed(mouseX, mouseY);

}
    

// METHODS --------------------------------------------------

void makeCrack() {
  if (num<maxnum) {
    // make a new crack instance
    cracks[num] = new Crack();
    num++;
  }
}


void begin() {
  // erase crack grid
  for (int y=0;y<dimy;y++) {
    for (int x=0;x<dimx;x++) {
      cgrid[y*dimx+x] = 10001;
      cugrid[y*dimx+x] = 10001;
      tgrid[y*dimx+x] = 0;
    }
  }
  
  // make random crack seeds
  //for (int k=0;k<16;k++) {
  //  int i = int(random(dimx*dimy-1));
  //  cgrid[i]=int(random(360));
  //}
  
  //Make cracks seeds in a circle in the center
  for (int k=0;k<16;k++) {
    float x;
    float y;
    int t = int(random(360));
    x=15*cos(t*PI/180) + dimx/2;
    y=15*sin(t*PI/180) + dimy/2;
    cgrid[int(y)*dimx+int(x)] = t;
    cugrid[int(y)*dimx+int(x)] = random(-cuMax,cuMax); //Range of curvature
    tgrid[int(y)*dimx+int(x)] = millis();
  }

  // make just 6 cracks
  num=0;
  for (int k=0;k<6;k++) {
    makeCrack();
  }
  background(bgColor);
}

// COLOR METHODS ----------------------------------------------------------------

color somecolor() {
  // pick some random good color
  return goodcolor[int(random(numpal))];
}

void takecolor(String fn) {
  PImage b;
  b = loadImage(fn);
  image(b,0,0);

  for (int x=0;x<b.width;x++){
    for (int y=0;y<b.height;y++) {
      color c = get(x,y);
      boolean exists = false;
      for (int n=0;n<numpal;n++) {
        if (c==goodcolor[n]) {
          exists = true;
          break;
        }
      }
      if (!exists) {
        // add color to pal
        if (numpal<maxpal) {
          goodcolor[numpal] = c;
          numpal++;
        }
      }
    }
  }
}


// OBJECTS -------------------------------------------------------

class Crack {
  float x, y;
  float t;    // direction of travel in degrees
  float curvature;
  
  // sand painter
  SandPainter sp;
  
  Crack() {
    // find placement along existing crack
    findStart();
    sp = new SandPainter();
  }
  
  void findStart() {
    // pick random point
    int px=0;
    int py=0;
    
    // shift until crack is found
    boolean found=false;
    int timeout = 0;
    int i;
    while ((!found) || (timeout++>1000)) {
      px = int(random(dimx));
      py = int(random(dimy));
      i = py*dimx+px;
      if (cgrid[i]<10000 && timestampAge(i)){
        found=true;
      }
    }
    
    if (found) {
      // start crack
      int a = cgrid[py*dimx+px];
      float cu = random(-cuMax,cuMax); //New curvature
      
      if (random(100)<50) {
        a-=90+int(random(-2,2.1));
      } else {
        a+=90+int(random(-2,2.1));
      }
      
      startCrack(px,py,a,cu);
    } else {
      //println("timeout: "+timeout);
    }
  }
  
  // Finds a point in the grid and checks its timestamp. Older timestamps
  // have a lower probability of being chosen. Returns true or false which
  // is used to determine if new crack should start at this point.
  boolean timestampAge(int i) {
    boolean b = false;
    int timestamp = tgrid[i];
    if (millis() - timestamp < maxAge) 
      b = true;
    return b;
  }
   
  void startCrack(int X, int Y, int T, float Cu) {
    x=X;
    y=Y;
    t=T;//%360;
    curvature = Cu;
    x+=0.61*cos(t*PI/180);
    y+=0.61*sin(t*PI/180);  
  }
  
  float getWeight(float x, float y) {
    float w = (strokeRadius/dist(x, y, dimx/2, dimy/2))*200;
    if (w > 5) w = 5;
    if (w < 1) w = 0; 
    return w;
  }
             
  void move() {
    // continue cracking
    x+=0.42*cos(t*PI/180);
    y+=0.42*sin(t*PI/180); 
    
    // line fuzz
    float z = 0.33;
    int cx = int(x+random(-z,z)); 
    int cy = int(y+random(-z,z));
    //no fuzz on wide stroke
    if(useStroke) {
      cx = int(x);
      cy = int(y);
    }
    
    // draw sand painter
    if(useColors)
      regionColor();
    
    // draw crack
    stroke(crackColor);
    float weight = 0.5;
    if (useStroke)
      weight = getWeight(x,y);
    strokeWeight(weight);
    
    // If stroke is off use line fuzziness
    // Here is the drawing of the lines
    if (!useStroke)
      point(x+random(-z,z),y+random(-z,z));
    else
      point(x,y); 

    if ((cx>=0) && (cx<dimx) && (cy>=0) && (cy<dimy)) {
      // safe to check
      if ((cgrid[cy*dimx+cx]>10000) || (abs(cgrid[cy*dimx+cx]-t)<5)) {
        // continue cracking
        if (cugrid[cy*dimx+cx] < 10001)
          t += curvature; //angle the line
        cgrid[cy*dimx+cx]=int(t);
        cugrid[cy*dimx+cx]=curvature;
        tgrid[cy*dimx+cx] = millis();
      } else if (abs(cgrid[cy*dimx+cx]-t)>2) {
        // crack encountered (not self), stop cracking
        findStart();
        makeCrack();
      }
    } else {
      // out of bounds, stop cracking
      findStart();
      makeCrack();
    }
  }
  
  void regionColor() {
    // start checking one step away
    float rx=x;
    float ry=y;
    boolean openspace=true;
    
    // find extents of open space
    while (openspace) {
      // move perpendicular to crack
      rx+=0.81*sin(t*PI/180);
      ry-=0.81*cos(t*PI/180);
      int cx = int(rx);
      int cy = int(ry);
      if ((cx>=0) && (cx<dimx) && (cy>=0) && (cy<dimy)) {
        // safe to check
        if (cgrid[cy*dimx+cx]>10000) {
          // space is open
        } else {
          openspace=false;
        }
      } else {
        openspace=false;
      }
    }
    // draw sand painter
    sp.render(rx,ry,x,y);
  }
  
}

class SandPainter {

  color c;
  float g;

  SandPainter() {

    c = somecolor();
    g = random(0.01,0.1);
  }
  void render(float x, float y, float ox, float oy) {
    // modulate gain
    g+=random(-0.050,0.050);
    float maxg = 1.0;
    if (g<0) g=0;
    if (g>maxg) g=maxg;
    
    // calculate grains by distance
    //int grains = int(sqrt((ox-x)*(ox-x)+(oy-y)*(oy-y)));
    int grains = 64;

    // lay down grains of sand (transparent pixels)
    float w = g/(grains-1);
    for (int i=0;i<grains;i++) {
      float a = 0.1-i/(grains*10.0);
      strokeWeight(1);
      stroke(red(c),green(c),blue(c),a*256);
      point(ox+(x-ox)*sin(sin(i*w)),oy+(y-oy)*sin(sin(i*w)));
    }
  }
}

// j.tarbell   June, 2004
// Albuquerque, New Mexico
// complexification.net

//https://kdoore.gitbook.io/cs1335-java-and-processing/object-oriented-programming/slider_controller

//Class slider 
//creates a horizontal slider
//uses map function to match displayed slider rectangle and 
//indicatror rectangles with the min, max values provided as input parameters
class Slider {
  float x, y;
  float w, h;
  float min, max;
  float sliderX;
  float sliderVal;
  String label;


  Slider( float x, float y, float w, float h, float min, float max, String label) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.min = min;
    this.max = max;
    this.label = label; 

    sliderX = x + (w/2);
    sliderVal = map( sliderX, x, x+w, min, max);

  }

  //display split into 2 methods, the background layer displayes 
  void display() {
    backgroundLayer();

    fill(100);
    rect( x, y, w, h);   //slider rectangle  - this is changed in child classes 

    fill(130); //inidcator rectangle
    rect( sliderX-2, y-3, 4, h + 6);
    text( int(sliderVal), sliderX + 2, y-4);  //display the sliderValue

}
  //display background rectangle that has text display 
  //for min, max, label
  void backgroundLayer() {
    pushStyle();
    fill( 255); 
    stroke(255);
    rect( x-10, y-20, w+20, h+40);  ////outer background rectangle
    fill(0);  //fill for the text
    // Create text for min, max, label - displayed under slider rectangle
    textSize( 12);
    textAlign(LEFT);
    int decimals = min > 10 ? 0 : 1;
    String minStr = nf(min, 0, decimals);
    text( minStr, x, y+h+15);
    textAlign(RIGHT);
    decimals = max > 10 ? 0 : 1;
    String maxStr = nf(max, 0, decimals);
    text( maxStr, x+w-10, y+h+15);
    textAlign(CENTER);
    textSize(14);
    text( label, x+(w/2), y+h +15);
    popStyle();
  }

  void setSliderVal( float sliderVal) {
    this.sliderVal = sliderVal;
    this.sliderX = map( sliderVal, min, max, x, x+w);
  }

  //test mouse coordinates to determine if within the slider rectangle
  //if not changed, return false
  //set sliderX to current mouseX position
  boolean checkPressed(int mx, int my) {
    boolean isChanged = false;
    if ( mx >= x && mx <= x+w && my> y && my< y +h) { //test for >= so endpoints are included
      isChanged = true;
      sliderX = mx;
      sliderVal = map( sliderX, x, x+w, min, max);
    }
    return isChanged;
  }
} // end class Slider
