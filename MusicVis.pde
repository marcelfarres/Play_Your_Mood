class MusicVis {
  
  ArrayList<Emitter> emitters;
  int n_emitter;
  
  PVector gravity;

  PGraphics buf;

  AudioMetaData meta;

  int c, emit_rate;

  public MusicVis (){
    // variables init 
    emitters = new ArrayList<Emitter>();
    gravity  = new PVector(0, 1);
    
    buf = createGraphics(width, height);
    
    emit_rate = 1; // if your computer are running at 20 fps, if not change to ¬
    // emit_rate = 2; // if your computer are running at 12 fps with emit_rate = 1; 
    
    // Environment setup
    clearTrails();
  }
  
  public void clearTrails(){
    // Clear the traces buffer.
    buf.beginDraw();
    buf.smooth();
    buf.background(0);
    buf.endDraw();    
  }
 
  
  public void draw(){
    // Draw the traces from the previous iteration 
    image(buf, 0, 0);
    
    // Draw the particles
    buf.beginDraw(); // Activate the particle trace buffer 
    for (Emitter em: emitters){
      // Update positions of the particles.
      em.run(buf, gravity);
      
      // Control particles emissions 
      if (frameCount%emit_rate==0) { 
        em.emit();
      }
    }
    // Create vanish effect 
    buf.fill(0, 0, 0, 20);
    buf.noStroke(); 
    buf.rect(0, 0, width, height);
    buf.endDraw(); // Deactivate the particle trace buffer 

    // Draw Meta-data of the song
    drawMetadata();
  }
  
  public void createEmitters (int n) {
    float angle;
    PVector point, coord;
    float r        = 80;
    PVector center = new PVector (width/2, height/2);
    
    // Save emitters number
    this.n_emitter = n;
    
    // Create emitters along a circle 
    for (int i = 0; i < n_emitter; i++){
      // Map number of emitters to the circle angle and r position
      angle = map(i, 0, n_emitter,0,TWO_PI);
      point = new PVector(r*cos(angle), r*sin(angle));
      coord = PVector.add(center, point);
      // Add the emitter
      emitters.add(new Emitter
                  (coord.get(), 
                  PVector.sub( PVector.mult(point,1.5), point), 
                  center, r, i ));  
    }
    
  }

  public void updateEmmiters (float[] bands){
    // Update the next iteration FFT value for each emitter
    for (int i = 0; i < n_emitter; ++i) {
      Emitter em = emitters.get(i);
      em.updateEmmiter(bands[i]);
    }
  }

  public void updateEmmiters (int c){
    // Set the saturation color for the emitters (mood color)
    for (Emitter em: emitters){
      em.updateEmmiter(c);
    }
  }

  public void updateMeta(AudioMetaData meta) {
    // Save the song meta-data (in order to display it later)
    this.meta = meta;
  }

  public void updateMetaC(int c) {
    // Update Meta-data Color 
    this.c = c;
  }

  public void drawMetadata() {
    textSize(26);
    fill(this.c, 40, 200, 255);
    if (meta != null){
      // text("File Name: " + meta.fileName(), 0, 30); // Debug
      text("Title: " + meta.title(), 30, height - 50);
      text("Author: " + meta.author(), 30, height - 30); 
      text("Album: " + meta.album(), 30, height - 10);
    } else {
      println("Metadata is null! ");
    }
  }

  public void reset (){
    // Reset band_max of all the emitters
    for (Emitter em: emitters){
      em.resetEmmiter();
    }
    // Clear the particles trace image
    clearTrails();
  }

  
};



