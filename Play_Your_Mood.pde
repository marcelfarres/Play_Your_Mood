import ddf.minim.analysis.*;
import ddf.minim.*;
import processing.net.*;

// Add time stamp to every error message or console output 


FontMng fontm; // Used to unify all the fonts 
MusicVis musv; // Holds all related to music vis 
MusicMng musm; // Holds all related to music player and play-list 
FileMng filem; // Read the data extracted from essentia 
ConnMng conm;  // Get and parse the data from the server
MoodMng moodmn;// Holds all related to mood data and vis
Client c;      // This is the client used by conm
Minim minim;   // This is the Minim object use by musm 

// debug 
boolean debug    = true;
float setup_time = 0;
float vis_time   = 0;
float modul_time = 0;

void setup() {
  setup_time = millis();

  println("Beg setup"); // debug
  
  switch (platform) {
    case MACOSX :
      open(sketchPath("")+"/code/enobio2Mood/enobio2Mood");
      println ("You are using a dummy server ! ! ! ");
      // open("python "+sketchPath("")+"/parser_script.py"); //  not working 
      // Runtime.getRuntime().exec("python "+sketchPath("")+"parser_script.py"); // not working 
      break;   
    case WINDOWS :
      open(sketchPath("")+"/code/eggMood/enobio2Mood/enobioFileClient/enobioFileClient.exe");
      // println("Not yet implemented, missing the server");
      break;  
  }

  // Environment configuration 
  colorMode(HSB, 360, 100, 100, 255);
  background(0);
  size(1200, 700, OPENGL);
  frameRate(26);  
  smooth();
  
  // Variables initialization 
  minim = new Minim(this); 
  c     = new Client(this,"127.0.0.1" , 8080); 
  // c = new Client(this, "192.168.1.133" , 8080); 
  
  // Class initialization
  filem  = new FileMng();
  fontm  = new FontMng();
  musv   = new MusicVis();
  musm   = new MusicMng(musv, filem, minim, fontm);
  moodmn = new MoodMng(musv, fontm);
  conm   = new ConnMng(c,moodmn, musm);

  if (debug){
    setup_time -= millis(); // debug
    println("setup_time: "+setup_time); // debug
  }
}

void draw() {
  // Update and Draw
  background(0); // Clean the frame
  musm.updateData(); // Update Music Data
  conm.updateData(); // Update Data from the server
  musv.draw(); // Draw Music vis
  moodmn.draw(); // Draw Mood vis 

  // Show Frame Rate
  if (debug) {
    fill(color(90,100,100));// debug
    textSize(14);// debug
    text( "Frame Rate: "+str(frameRate), 10, 20 );// debug
  }
}

void mousePressed() {
 
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
  conm.close();
  super.exit();
}
