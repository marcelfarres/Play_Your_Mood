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

////////////////////////////////////////////////////////////////////////////////////////////////////
class DataColl {
  // Config 
  IntList targets; 
  int repetitons;
  int dur;
  int rest;

  // Controll
  int elapsed;
  int total_t;
  int mode;
  int index;

  // Data & Vis
  ArrayList <Data> all_data;
  Data temp_data;
  int start_t, end_t;

  String[] moods;
  int[] col;
  PVector center = new PVector(width/2, height/2); // Center

  public DataColl(String[] moods, int[] col) {
    // Config 
    dur        = 2 * 1000;
    rest       = 1 * 1000;
    repetitons = 5;

    targets = new IntList();
    for (int i = 0; i < 4; ++i) {
      for (int j = 0; j < repetitons; ++j) {
        targets.append(i);
      }
    }
    targets.shuffle();

    mode  = 0;
    index = 0; 

    // Data & Vis
    temp_data  = new Data();
    all_data   = new ArrayList<Data>();
    start_t    = millis ();
    total_t    = 0;
    this.moods = moods; 
    this.col   = col;
  }

  public void sampleControll (int last_mood) {
    end_t   = millis ();
    elapsed = end_t - start_t;
    total_t = total_t + elapsed;
    start_t = end_t;    

    switch (mode) {
      case 0 :
        if (total_t>rest) {
          mode    = 1;
          total_t = 0;
        }
      break;  
      case 1 :
        if (total_t>dur) {
          mode    = 0;
          newSample(targets.get(index));
          index   = index + 1;
          total_t = 0;
        }else {
          temp_data.m_time[last_mood] = temp_data.m_time[last_mood] + elapsed;
        }
      break;  
    }

    if (index > repetitons * 4 - 1) {
      exit();
    }
  }

  public void newSample (int target){
    println("temp_data.target: "+temp_data.target);
    for (int i = 0; i < 4; ++i) {
      println("temp_data.m_time[i]: "+i+" "+temp_data.m_time[i]);
    }
    all_data.add(new Data(temp_data.target, temp_data.m_time));
    temp_data.reset(target);
    // for (Data o : all_data) {
    //   for (int i = 0; i < 4; ++i) {
    //     println("o.m_time[i]: "+i+" "+o.m_time[i]);
    //   }
    // }
  }

  public void draw() {
    String message = "";

    switch (mode) {
      case 0 :
        message = "Break Time";
        fill(color (0, 0, 255),255);
      break;  
      case 1 :
        message = moods[targets.get(index)];
        fill(color (col[targets.get(index)], 40, 200),255);
      break;  
    }
    textFont(fontm.fonts_data[0]); // 0 funciona 
    textSize(60);
    text(message, width - 330,  height - 50);

  }

};

////////////////////////////////////////////////////////////////////////////////////////////////////
class Data {
  int target;
  int[] m_time;

  public Data () {
    target    = 0; 
    m_time    = new int [4];
    m_time[0] = 0;
    m_time[1] = 0;
    m_time[2] = 0;
    m_time[3] = 0;
  }

  public Data (int t, int[] m_t) {
    target = t; 
    m_time    = new int [4];
    m_time[0] = m_t[0];
    m_time[1] = m_t[1];
    m_time[2] = m_t[2];
    m_time[3] = m_t[3];
  }

  public void reset (int t){
    target    = t; 
    m_time[0] = 0;
    m_time[1] = 0;
    m_time[2] = 0;
    m_time[3] = 0;
  }

  // a la hora de fer print a la sortida.
  // public String[] Print () {
  //   return ;
  // }

};