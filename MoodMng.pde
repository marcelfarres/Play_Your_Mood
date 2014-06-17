class MoodMng {

  FontMng fontm;
  MusicVis musv;

  ArrayList<MoodVis> moodsvis;
  ArrayList<PowerVis> powersvis;
  

  String [] moods     = {"Relaxed", "Sad", "Angry", "Happy"}; // Mood string (order matter)
  float[] starts      = {0, HALF_PI, PI, PI+HALF_PI}; // Circle angle for each mood
  int[] col           = {240, 290, 0, 60}; // Color of each mood 
  int last_mood       = 0; // Control mood changes 
  boolean mood_change = true; 
  PVector max_mood; // Hold mood data (coefficient, color and mood index )
  float arousal, valence;
  float ecg, hbr;


  
  public MoodMng (MusicVis musv, FontMng fontm){
    // Save MusicVis and FontMng
    this.musv  = musv;
    this.fontm = fontm;
    
    // Create Vis Objects array
    moodsvis   = new ArrayList<MoodVis>();
    powersvis  = new ArrayList<PowerVis>();
    
    // Initialize vars
    arousal    = 0;
    valence    = 0;
    ecg        = 0;
    hbr        = 0;

    // Create the Vis Objects
    this.createMoodVis();
    this.creatPowerVis(); 
  }

  public void createMoodVis() {
    // Create Center Mood representation
    for (int i = 0; i < moods.length; ++i) {
      moodsvis.add(new MoodVis(1,moods[i], starts[i], col[i],i));
    }
  }

  public void creatPowerVis() {
    // Create top left and right arousal valence representation
    powersvis.add(new PowerVis (true) );
    powersvis.add(new PowerVis (false) );
  }

  public void updateMoods(float [] moods_coef) {
    // Get update moods, update representation and find the max.
    max_mood = new PVector(0,0);
    for (int i = 0; i < moods.length; ++i) {
      MoodVis m = moodsvis.get(i);
      m.updateMoodVis(moods_coef[i]);
      if (max_mood.x<moods_coef[i]) {
        max_mood.x = moods_coef[i];
        max_mood.y = col[i];
        max_mood.z = i;
      }
    }

    // If there is a mood change update emitters and meta-data color,  
    // and activate mood_change flag used in connection manager to change  
    // music manager active song list.
    if (last_mood != int(max_mood.z)) {
      musv.updateEmmiters(int(max_mood.y));
      musv.updateMetaC(int(max_mood.y));
      last_mood   = int(max_mood.z);
      mood_change = true;
    }
  }
    
  public void updatePowers(float [] powers_coef) {
    // Update valence and arouse power values
    for (int i = 0; i < 2; ++i) { 
      PowerVis p = powersvis.get(i);
      p.updatePower(powers_coef[i]);
    }
  }

  public int getMood() {
    // Return the current max Mood.
    return int(max_mood.z);
  }

  public boolean getMoodChange() {
    // If in the iteration there is a max mood change 
    // this function will return true. 
    if (mood_change) {
      mood_change = false;
      return true;
    }
    else {
      return false;
    }
  }
  
  public void draw(){
    /* draw the moods circles*/
    for (MoodVis m : moodsvis) {
      m.draw();
    }
    /* draw the valence and arousal powers*/
    for (PowerVis p : powersvis) {
      p.draw();
    }
  }

};

