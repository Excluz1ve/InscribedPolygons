//  Inscribed Geometry
//    Jared Tarbell
//    November 28, 2014

float[][] points;
int maxPoints = 20000;
int numPoints = 0;


void setup() {

  size (1300,1300);
  
  background(0);
  smooth();
  
  points = new float[maxPoints][2];
  
  int gridx = 5;
  int gridy = 5;
  float pad = 0;
  float spcx = (width-gridx*pad)/gridx;
  float spcy = (height-gridy*pad)/gridy;
  
  for (float xx=0;xx<gridx;xx++) {
    for (float yy=0;yy<gridy;yy++) {

      // hexagonal layout
      float offx = spcx/2;
      float offy = spcy/2;
      //if (yy%2==0) offx+=spcx/2;
      float px = offx+(spcx+pad)*xx;
      float py = offy+(spcy+pad)*yy;
      
      // grid of all inscriptions
      //int ss = floor(yy);
      //float rr = random(TWO_PI);
      //NGon neo = new NGon(0,ss,px,py,rr,min(spcx,spcy)/2);
      //neo.inscribe(floor(xx));
      
      // random inscriptions
      int ss = 2;
      while (ss==2 || ss==1) ss = floor(random(0,7));
      float ir = -HALF_PI;
      NGon neo = new NGon(0,ss,px,py,ir,min(spcx,spcy)/2);
       
    }
  }
  
  //connectPoints();
}

void connectPoints() {
  // randomly connect some points
  for (int k=0;k<200000;k++) {
    int n0 = floor(random(numPoints));
    int n1 = floor(random(numPoints));
    float x0 = points[n0][0];
    float y0 = points[n0][1];
    float x1 = points[n1][0];
    float y1 = points[n1][1];
    
    float d = sqrt((x0-x1)*(x0-x1)+(y0-y1)*(y0-y1));
    if (d<80) {
      
      stroke(0,0,255,100);
      line(x0,y0,x1,y1);
    }
  }
    
}

void draw() {
  //for (int k=0;k<100;k++) {
// if (random(100)<2) background(0);
 // }
}

void keyPressed() {
//  saveFrame("inscribeGeometry####.png");
//  println("Saved frame.");
}

void registerPoint(float x, float y) {
  if (numPoints<maxPoints) {
    points[numPoints][0] = x;
    points[numPoints][1] = y;
    numPoints++;
  }
}

class NGon {
  int gen = 0;
  int sides = 0;
  float x;
  float y;
  float rotation;
  float H;
  float h;
  float base;
  float vertex;
  
  NGon child;
  NGon parent;
 
  NGon(int generation, int side_count, float x_position, float y_position, float rot, float height_to_extents) {
    gen = generation;
    sides = side_count;
    x = x_position;
    y = y_position;
    rotation = rot;
    
    setH(height_to_extents);
    
    //report();
    
    render();
    
    if (gen<11) {
      int ss = 2;
      while(ss==1 || ss==2 || ss==sides) ss = floor(random(0,7));
      inscribe(ss);
    }
  }
  
  void setH(float newH) {
    H = newH;
    
    // compute h and base length
    float theta = TWO_PI;
    if (sides>2) {
      theta = (PI-(TWO_PI/sides))/2;
      h = H*sin(theta);
      base = 2*H*cos(theta);
      vertex = 2*theta;
      // special rotation for square
      if (sides==4 && gen==0) {
        rotation = -QUARTER_PI;
      }
    } else if (sides==2) {
      // LINE
      h = 0;
      base = H;
      vertex = PI;
    } else if (sides==1) {
      // POINT
      h = 0;
      base = 0;
      vertex = PI; 
    } else {
      // CIRCLE
      h = H;
      base = 0;
      vertex = TWO_PI;
    }
  }
  
  void report() {
    float dv = degrees(vertex);
    println("NGon "+sides+" sides at "+x+","+y);
    println("         H:"+H+",  h:"+h+",  base:"+base+", vertex:"+dv);
  }
  
  void render() {
    noFill();
    stroke(255,63);
    
    if (sides==0) {
      // circle
      ellipse(x,y,H*2,H*2);     
    } else if (sides==1) {
      // point
      stroke(255);
      point(x,y);
    } else if (sides==2) {
      // line
      float x0 = x+H*cos(rotation);
      float y0 = y+H*sin(rotation);
      
      float x1 = x+H*cos(PI+rotation);
      float y1 = y+H*sin(PI+rotation);
      
      line(x0,y0,x1,y1);
      registerPoint(x0,y0);
      registerPoint(x1,y1);
     } else {
      // polygon
      float omega = rotation;
      float omegaDelta = TWO_PI/sides;
      for (int n=0;n<sides;n++) {
        float x0 = x+H*cos(omegaDelta*n+omega);
        float y0 = y+H*sin(omegaDelta*n+omega);
        
        int k = (n+1)%sides;
        float x1 = x+H*cos(omegaDelta*k+omega);
        float y1 = y+H*sin(omegaDelta*k+omega);
        
        line(x0,y0,x1,y1);
        
        registerPoint(x0,y0);
      } 
    }
    
    // render children
    if (child!=null) child.render();
      
  }
  
  NGon inscribe(int nsides) {
    float newx = x;
    float newy = y;
    float nrotation = rotation;
    float nH = H;
    
    
    if (sides==0) {
      // circle is easy to inscribe, no transformations to do    
    } else if (sides==1 || sides==2) {
      // point or straight line is impossible to inscribe, ignore
      return null;
    } else if (sides==3) {
      // equilateral triangle
      if (nsides==0) { 
        // circle inscribed in equilateral triangle
        nH = h;
      } else if (nsides==2) {
        // line inscribed in equilateral triangle
        nH = (h+H)/2;
        float r = (H-h)/2;
        newx += r*cos(nrotation);
        newy += r*sin(nrotation); 
      } else if (nsides==3) {
        // equilateral triangle inscribed in equilateral triangle
        nH = h;
        nrotation = rotation+PI;
      } else if (nsides==4) {
        // square inscribed in equilateral triangle
        // calculate side of square
        float sqrSide = base*(h+H)/(base+h+H);
        // calculate new radius of square
        nH = sqrSide/sqrt(2);
        nrotation = rotation - QUARTER_PI;
        float r = -(h-sqrSide/2);
        newx += r*cos(rotation);
        newy += r*sin(rotation); 
      } else if (nsides==5) {
        // pentagon inscribed in equilateral triangle
        nH = h*1.08;  // estimate
        float r = -H*.07;
        newx += r*cos(nrotation);
        newy += r*sin(nrotation); 
      } else if (nsides==6) {
        // hexagon inscribed in equilateral triangle
        nH = h;  // esimate
      } else {
        // estimate all other polygons
        nH = h;
      }
        
    } else if (sides==4) { // square
      if (nsides==0) {
        // circle inscribed in square
        nrotation = rotation - QUARTER_PI;
        nH = h;
      } else if (nsides==2) {
        // line inscribed in a square
        nH = H;
      } else if (nsides==3) {
        // triangle inscribed in square
        if (gen%2==0) {
          nrotation = rotation - QUARTER_PI;
        } else {
          nrotation = rotation + QUARTER_PI;
        }
        nH = base/sqrt(3);
        float r = -h+nH/2;
        newx += r*cos(nrotation);
        newy += r*sin(nrotation); 
      } else if (nsides==4) {
        // square inscribed in square
        nrotation = rotation - QUARTER_PI;
        nH = h;
      } else if (nsides==5) {
        // pentagon inscribed in square
        nrotation = rotation - QUARTER_PI;
        nH = base*.53;
        float r = -nH*.144;
        newx += r*cos(nrotation);
        newy += r*sin(nrotation);        
      } else if (nsides==6) {
        // hexagon inscribed in square
        nrotation = rotation - QUARTER_PI;
        nH = base*.5;
      } else {
        // estimate all others
        nH = h;
      }
      
    } else if (sides==5) { // pentagon
      if (nsides==0) {
        // circle inscribed in a pentagon
        nH = h;
      } else if (nsides==2) {
        // line inscribed in a pentagon
        nH = (h+H)/2;
        float r = (H-h)/2;
        newx += r*cos(nrotation);
        newy += r*sin(nrotation);        

      } else if (nsides==3) {
        // triangle inscribed in a pentagon
        nH = H*.858;
        float r = H*.14;
        newx += r*cos(nrotation);
        newy += r*sin(nrotation);        
        
      } else if (nsides==4) {
        // square inscribed in a pentagon
        nH = H*.88;
        float r = H*.09;
        newx += r*cos(nrotation);
        newy += r*sin(nrotation);        

      } else if (nsides==5) {
        // pentagon inscribed in a pentagon
        nrotation = rotation + PI;
        nH = h;
      } else if (nsides==6) {
        // hexagon inscribed in a pentagon
        nH = H*.84;
        float r = H*.044;
        newx += r*cos(nrotation);
        newy += r*sin(nrotation);        

      } else {
        // estimate all other polygons
        nH = h;
      }
    } else if (sides==6) { // hexagon
      if (nsides==0) {
        // circle inscribed in hexagon
        nH = h;
      } else if (nsides==2) {
        // line inscribed in a hexagon
        nH = H;
      } else if (nsides==3) {
        // triangle inscribed in hexagon
        nrotation = rotation + PI/6;
        nH = h;
      } else if (nsides==4) {
        // square inscribed in hexagon
        nH = h;
      } else if (nsides==5) {
        // pentagon inscribed in hexagon
        nH = H*.91;
        float r = H*.04;
        newx += r*cos(nrotation);
        newy += r*sin(nrotation);        
        
      } else if (nsides==6) {
        // hexagon inscribed in hexagon
        nrotation = rotation + PI/6;
        nH = h;
      } else {
        // estimate all others
        nH = h;
      }
            
    }
    
    // now create the new polygon
    // NGon(int generation, int side_count, float x_position, float y_position, float rot, float height_to_extents) {
    child = new NGon(gen+1, nsides, newx, newy, nrotation, nH);
    
    return child;
    
  }
  
  NGon circumscribe(int nsides) {
    // TODO
    parent = new NGon(gen+1, nsides, 0,0,0,0);
    return parent;
  }
}
