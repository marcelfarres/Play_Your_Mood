import ddf.minim.analysis.*;
import ddf.minim.*;
import processing.net.*;

// Add time stamp to every error message or console output 


FontMng fontm; // Used to unify all the fonts 
MusicVis musv; // Holds all related to music vis 
MusicMng musm; // Holds all related to music player and play-list 
FileMng filem; // Read the data extracted from essentia 
MoodMng moodmn;// Holds all related to mood data and vis
Minim minim;   // This is the Minim object use by musm 

// debug 
float setup_time   = 0;
float vis_time     = 0;
float modul_time   = 0;
float [] mood_coef = {1.0, 0.6, 0.2, 0.8};

void setup() {
  setup_time = millis();

  println("Beg setup"); // debug

  // Environment configuration 
  colorMode(HSB, 360, 100, 100, 255);
  background(0);
  size(1200, 700, OPENGL);
  frameRate(26);  
  smooth();
  
  // Variables initialization 
  minim = new Minim(this); 
  
  // Class initialization
  filem  = new FileMng();
  fontm  = new FontMng();
  musv   = new MusicVis();
  moodmn = new MoodMng(musv, fontm);
  musm   = new MusicMng(musv, filem, minim, fontm, moodmn);
  
  setup_time -= millis();// debug
  println("setup_time: "+setup_time);// debug
}

void draw() {
  // Update and Draw
  background(0); // Clean the frame
  musm.updateData(); // Update Music Data
  musv.draw(); // Draw Music vis
  moodmn.draw(); // Draw Mood vis 

  // Show Frame Rate
  fill(color(90,100,100));// debug
  textSize(14);// debug
  text( "Frame Rate: "+str(frameRate), 10, 20 );// debug
  moodmn.updateMoods(mood_coef);
}

void mousePressed() {
  mood_coef = new float [4];
  if ((mouseX>width/2) && (mouseY>height/2)) {
    mood_coef[0]=1;
    println("This is state number 1 and mood Relaxed");
  } else if ((mouseX>width/2) && (mouseY<height/2)) {
    mood_coef[3]=1;
    println("This is state number 2 and mood Happy");
  } else if ((mouseX<width/2) && (mouseY>height/2)) {
    mood_coef[1]=1;
    println("This is state number 3 and mood Sad");
  } else if ((mouseX<width/2) && (mouseY<height/2)) {
    mood_coef[2]=1;
    println("This is state number 4 and mood Angry");
  }
}

 // DEBUG //
void keyPressed(){
  if (key == 'n' ) {
    musm.nextSong();
  }else if (key == 'p') {
    musm.pauseSong();
  }

}

void exit(){
  // Close all the stuff needed
  println("We are on exit !");
  musm.close();
  super.exit();
}
