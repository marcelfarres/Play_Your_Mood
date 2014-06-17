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
    // falta font i reductor d'alliasing !!! 
    textFont(fontm.fonts_data[0]); // 10 funciona 
    fill(color (col, 40, 200),old_coef*255);
    textAlign(align[0], align[1]);
    textSize(26*old_coef);
    text(mood, center.x, center.y);
  }

};