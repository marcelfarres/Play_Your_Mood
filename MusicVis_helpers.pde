////////////////////////////////////////////////////////////////////////////////////////
class Emitter {
  ArrayList<Particle> particles;
  
  PVector pos, direction, center;
  float tSpeed, r;
  float band_coef, band_max;
  int c;
  
  public Emitter(PVector pos, PVector direction, PVector center, float r, int band){  // create structure prepare emiter.
    // Create the particles array
    particles = new ArrayList<Particle>();
    
    // Init the variables
    this.pos       = pos;
    this.direction = direction;
    this.center    = center;
    this.r         = r;
    this.band_coef = 0.0;
    band_max       = 0.0;
    tSpeed         = 0.0;
  }
  
  public void run (PGraphics buf, PVector g){
    // For each particle:
    //  - Apply Force 
    //  - Check with center circle collision 
    //  - Update position 
    //  - Check if the particle is death if not draw it. 

    // Buf is already activated and deactivate outside (better performance)
    for (int i = particles.size()-1; i >= 0; i--){
      Particle p = particles.get(i);
      p.applyForce(PVector.mult(g, p.mass));
      p.checkZone(center, r);
      p.update();
      if (p.isDead()){
        particles.remove(i);
      }else {
        p.draw(buf);   
      }
    }
  }

  public void emit(){
    // Add a new particle to the emitter. 
    Particle p;
    tSpeed += 0.1;
    if (band_coef>0.01){  // If the particle will be too small, stop emission.
        p = new Particle(PVector.add(pos, direction), // Initial position 
                          PVector.mult(direction, 0.2+noise(tSpeed)*0.2), // noisy speed 
                          4*band_coef, // particle mass 
                          color( c, 10+random(50), 200) ); // particle color (HSV)
        particles.add(p); // add the particle to the particle array
      }
  }
  
  public void updateEmmiter (float b_coef){
    // Update the band max value
    band_max       = max(b_coef,band_max);
    // Map the current band coef (form 0 to band max ) to 0-1
    this.band_coef      = map(b_coef, 0, band_max, 0, 1);
    // Subtract 1% from the current max (adapt the max to music dynamics)
    band_max -= band_max/100;
  }

  public void updateEmmiter (int c){
    // Change Emitter color
    this.c = c;
  }

  public void resetEmmiter() {
    // Reset max band value
    this.band_max = 0;  
  }
  
};


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
class Particle{
  PVector pos; // Particle position 
  PVector vel; // Particle velocity 
  PVector acc; // Particle acceleration 
  float mass,lifespan, d, e; // Particle mass, lifespan, distance to the center and differentiation factor 
  PVector prevPos; // Previous particle position 
  color c; // Particle color (HSV)
  
  public Particle(PVector pos, PVector vel, float mass, color c){  // create structure prepare particle.
    acc           = new PVector(0, 0);
    this.pos      = pos;// repassar ! debug
    prevPos       = pos.get();
    this.vel      = vel;
    this.mass     = mass;
    // If the mass is bigger (more power in the band) give to the particle more velocity 
    if (mass>3.7) {
      this.vel.mult(1.4);
    }else if (mass > 3) {
      this.vel.mult(1.2);
    }
    this.c        = c;
    this.lifespan = 255.0 - 40 + random(80); // Variable lifespan 
    e             = 0;
  }
  
  public void applyForce(PVector force){
    acc.add(PVector.div(force, mass));
  }
  
  public void update(){
    prevPos = pos.get(); // save the previous position 
    
    // Depending on the y axis position, invert y acceleration, then compute velocity 
    if (pos.y > height/2){
      vel.add(acc.x, -acc.y, 0);
    }
    else{
      vel.add(acc.x, acc.y, 0);
    }
    
    // Update position 
    pos.add(vel);
    // Reset acceleration 
    acc.mult(0);
    // Update lifespan
    lifespan -= 5; 
  }

  public void checkZone (PVector c, float r){
    // Check if the particle is in the mood-visualizer zone, if it's true, 
    // change particle acceleration to avoid it 
    d = (pos.y-c.y)*(pos.y-c.y) + (pos.x-c.x)*(pos.x-c.x);
    if ( d < (1.49*r)*(1.49*r)){ 
      if (pos.x+random(1)-0.5>c.x){
        e = 1;
      }
      else{
        e = -1;
      }
      acc.set( random(e*0.4,max(acc.x,.1)*e*8)-0.1, (-10*d*acc.y)/((1.49*r)*(1.49*r)), 0);
    }
  }
  
  
  public void draw(PGraphics buf){
    // Other Vis Modes 
    // stroke(c, lifespan);
    // fill(c, lifespan);
    // noStroke();
    // fill(c, lifespan);
    // noFill();
    // stroke(c, lifespan);

    // Draw particle
    stroke(c, lifespan/2);
    fill(c, lifespan/4);
    ellipse(pos.x, pos.y, 1+mass*10, 1+mass*10);

    // Draw the path on the off-screen buffer 
    buf.line(prevPos.x, prevPos.y, pos.x, pos.y);
    buf.strokeWeight(3);
    buf.stroke(c,30); 
  }
  
  public boolean isDead(){
    // Check if the particle is outside the boundaries or lifespan is less than 0 
    if ( (pos.y<-60)||(pos.x<-60)||(pos.y>height+60)||(pos.x>width+60)||(lifespan < 0.0) ) 
      return true;
    else {
      return false;
    }
  }

};
////////////////////////////////////////////////////////////////////////////////////