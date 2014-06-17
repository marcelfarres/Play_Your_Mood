////////////////////////////////////////////////////////////////////////////////////////////////////
class MoodVis{
  //PShape s;
  float start, coef, r, col, old_coef;
  PVector center;
  String mood;
  int[] align;

  public MoodVis(float coef, String mood, float start, float col, int ali) {
    this.coef  = coef; // Mood normalized coefficient 
    old_coef   = coef; // Last frame coefficient 
    this.mood  = mood; // Mood name to display
    this.start = start; // Start angle
    this.col   = col; // Mood color
    this.align = new int [2]; // Align type (vertical and horizontal)
    r          = 200; // Max circle radius 
    center     = new PVector(width/2, height/2); // Center
    
    // Set the text align depending on position 
    switch (ali) {
      case 0 : 
        this.align[0] = LEFT;
        this.align[1] = TOP; 
        break;  
      case 1 : 
        this.align[0] = RIGHT;
        this.align[1] = TOP;
        break;  
      case 2 : 
        this.align[0] = RIGHT;
        this.align[1] = BOTTOM;
        break; 
      case 3 : 
        this.align[0] = LEFT;
        this.align[1] = BOTTOM;
        break;   
    }

  }

  public void updateMoodVis(float coef) {
    // Update the mood coefficient.
    this.coef = max (coef, 0.4);
    // Smooth the change
    float d = this.coef - old_coef;
    if (abs(d)>0.01){
      old_coef += d * 0.05;
    }
  }

  public void draw() {
    // Fill and draw with the mood color and alpha related to mood coef 
    fill(color (col, 70, 200),old_coef*200);
    noStroke();
    arc(center.x, center.y, r*old_coef, r*old_coef,
        start, start+HALF_PI );

    // Text the mood name related to mood coef
    textFont(fontm.fonts_data[0]); // 0 funciona 
    fill(color (col, 40, 200),old_coef*255);
    textAlign(align[0], align[1]);
    textSize(26*old_coef);
    text(mood, center.x, center.y);
  }

};

////////////////////////////////////////////////////////////////////////////////////////////////////
class PowerVis  {
  float old_power, text_max_power;
  int[] range;
  int[] p_size;
  int[] p_size_array;
  int[] alpha_value;
  String name;
  color c;
  boolean type; 

  public PowerVis (boolean type) {
    this.range  = new int [2]; // Bar initial position and end 
    this.p_size = new int [2]; // Bar pixel size 

    p_size[0] = 350; // x size
    p_size[1] = 100; // y size 
    
    this.type           = type; // left or right type 
    this.p_size_array   = new int[p_size[0]]; // lines y size 
    this.alpha_value    = new int[p_size[0]]; // lines alpha
    this.old_power      = 0.5; // default power 
    this.text_max_power = 0.8;

    if (type) { // if true --> Left side 
      range [0] = 0; 
      range [1] = p_size[0];
      name      = "Arousal";
      c         = color (48, 100, 100);
    }
    else { // false --> Right side 
      range [0] = width;
      range [1] = width - p_size[0];   
      name      = "Valence";    
      c         = color (130, 100, 100);
    }

    // Map bar y size and alpha value across x range
    for (int i = p_size[0]-1; i > 0 ; --i) {
      p_size_array[i] = (int) map(i, 0, p_size[0], p_size[1], 0 );
      alpha_value [i] = (int) map(i, 0, p_size[0], 60, 200) + 55; 
    }
  }

  public void updatePower(float power) {
    // Update power value (smooth it)
    power = map (power, -1, 1, 0, 1);
    float d = power - old_power;
    if (abs(d)>0.01){
      old_power += d * 0.05;
    }
  } 

  public void draw() {
    // Draw Arousal/Valence bars
    float p = min(old_power, text_max_power);
    if (type) {
      int r1 = (int) map(old_power, 0, 1, range[0], range[1]);
      textFont(fontm.fonts_data[0]); // 10 funciona 
      fill(color (50, 50, 50), 255);
      textSize(70*p);
      text(name, round (range[0]+p_size[0]*p/10), 0, min(r1,225), 40);
      for (int i = range[0]; i < r1; ++i) {
        stroke(c, alpha_value[i]);
        line(i, 0, i, p_size_array[i]);
      }

    }else {
      int r1 = (int) map(old_power, 0, 1, range[0], range[1]);
      textFont(fontm.fonts_data[0]); // 10 funciona 
      fill(color (100, 100, 100), 255);
      textSize(70*p);
      text(name, max(round(r1+p_size[0]*p/10), 995), 0, width, 40); // BUG Still problematic !
      // println("This is P1 "+str(round(r1+p_size[0]*p/7))+" 0"+"  This is P2 "+width+" 40");
      for (int i = range[0]-1; i > r1; --i) {
        stroke(c, alpha_value[width-i-1]);
        line(i, 0, i, p_size_array[width-i-1]);
      }
    }
  }

};
