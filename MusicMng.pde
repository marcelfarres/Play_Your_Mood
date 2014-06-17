class MusicMng {
  // Class var 
  Minim minim;
  FFT fft; 
  AudioPlayer player;
  JSONArray active_list;
  int sampleRate, bufferSize, min_freq, bad_oct;
  boolean pause;
  int zones;
  boolean [] played;
  
  // Instances of other classes needed
  MusicVis MV;
  FileMng FM;
  FontMng fontm;
  
  public MusicMng(MusicVis MV, FileMng FM, Minim minim, FontMng fontm){
    sampleRate = 44100;
    bufferSize = 1024;
    min_freq   = 87;
    bad_oct    = 2;

    this.minim = minim;
    // Is necessary?
    player = minim.loadFile(dataPath("")+"/mute.mp3", bufferSize);
    player.play();
    pause = false;

    fft   = new FFT(bufferSize, sampleRate);
    fft.window(FFT.HAMMING);
    fft.logAverages(min_freq, bad_oct);
    zones = fft.avgSize(); 

    // println("Total Bands: " + zones); // Debug

    // Save Music Vis and create the emitters depending of FFT resulting zones
    this.MV = MV;
    MV.createEmitters(zones);

    // Save the File Manager 
    this.FM = FM;

    // Save the Font Manager 
    this.fontm = fontm;

    // Create the active list array
    active_list = new JSONArray();

  } 

  public void setActiveList (int mood) {
    // Change the active list depending on the active mood.
    switch (mood) {
      case 0 : // Relaxed 
        active_list = FM.relaxed;
        break; 
      case 1 : // Sad
        active_list = FM.sad;
        break;
      case 2 : // Angry
        active_list = FM.angry;
        break;
      case 3 : // Happy
        active_list = FM.happy;
        break;  
     } 
    played = new boolean [active_list.size()];
  }

  public void nextSong() {
    // Play next song
    int total   = active_list.size();
    int partial = 0;
    MV.reset(); // Clean the traces frame. 

    // Get a random song from the active list 
    int song_numb = (int)random(total);
    while (played[song_numb] == true ) {
      println("The song: "+song_numb+" had been played before!");
      partial += 1;
      if (partial == total){
        played = new boolean [total];
        println("All the songs done, reset play-list! ");
      } 
      song_numb = (int)random(total);
    }
    played[song_numb] = true;

    JSONObject song = active_list.getJSONObject(song_numb);

    // Play the song
    println("NEW song path: "+song.getString("dir")+song.getString("file")+"\n   Song mood: "+song.getString("mood")+"/"+song.getFloat("p"));
    this.playSong(song.getString("dir")+song.getString("file"));
  }
  
  public void playSong(String s){
    File f = new File(s);
    if(!f.exists()){ // Check if the file exist, if not get another song 
      // println("The files is not here!");
      this.nextSong();
    } 

    // println("The file exists");
    if(player.isPlaying()){ // If a song is being played, stop the reproduction 
      minim.stop(); 
    } 

    try {
      // Load the next song and play it 
      player = minim.loadFile( s, bufferSize);
      player.play();
      // Get the metadata of the song and send to the Music Vis
      MV.updateMeta(player.getMetaData());
    }
    catch (Exception e) {
        // If there is an error, Report it and find a new song 
        println("Error: " + e);
        this.nextSong();
    }  
  }

  public void pauseSong() {
    // Pause/Resume the song 
    if (!pause) {
      player.pause();
      pause = true;
    }
    else {
      player.play();
      pause = false;
    }
  }

  public void updateData() {
    // Play a song if there is no song being play and pause is not active
    if((!player.isPlaying()) && (!pause)){
      this.nextSong();
    }

    // FFT calculations
    float[] averages ;
    averages = new float[zones];

    fft.forward(player.mix);

    for (int i = 0; i < zones; ++i) {
      averages[i] = fft.getAvg(i); 
    }
    
    // Update the emitters whit the new information. 
    MV.updateEmmiters(averages);
  }

  public void close(){
    // Close the player and stop the minim Obj
    player.close();
    minim.stop();
  }
  
};

// a fer servir logAverages
