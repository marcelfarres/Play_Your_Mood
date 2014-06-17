public class ConnMng {
  MoodMng moodmn;
  MusicMng musm; 
  
  Client client;

  String str;

  int req_rate;
  
  XML xml;

  public ConnMng (Client c, MoodMng moodmn, MusicMng musm) {
    float [] moods_coef  = { .0f, .0f, .0f, 1.0f};
    float [] powers_coef = { .5f, .5f};
    client      = c;
    this.moodmn = moodmn;
    this.musm   = musm;
    moodmn.updateMoods(moods_coef);
    moodmn.updatePowers(powers_coef);
    req_rate = 24;
    // test ! (not sure if necessary)
    // delay(1000);
    // client.clear();
    // client.write("mood");
    // delay(3);
    // str = client.readString();
  }

  public void updateData() {
    float [] moods_coef;
    moods_coef  = new float[4];
    float [] powers_coef;
    powers_coef = new float[2];
    
    // Control Request to the server (Try with frameRate global var)
    if (frameCount%req_rate==0) { 
      client.clear();
      client.write("mood");
      delay(3);
      str = client.readString();
      println("xml: "+xml); // debug
    }
    // Old way
    // client.clear();
    // client.write("mood");
    // delay(3);
    // str = client.readString();

    if (str != null){
      try { 
        // Comprovar final d'xml si coincideix principi sino tornar a enviar request
        xml = parseXML(str);
        if (xml == null) {
          println("XML could not be parsed. Send request again! (1)\n");
          updateData();
        } else {
          // println("xml: "+xml);
          XML[] children = xml.getChildren();
          moods_coef[0]  = xml.getFloat("relaxed");
          moods_coef[1]  = xml.getFloat("sad");
          moods_coef[2]  = xml.getFloat("angry");
          moods_coef[3]  = xml.getFloat("happy");
          moodmn.updateMoods(moods_coef);
          
          moodmn.arousal = xml.getFloat("arousal");
          moodmn.valence = xml.getFloat("valence");
          powers_coef[0] = moodmn.arousal;
          powers_coef[1] = moodmn.valence;
          moodmn.updatePowers(powers_coef);
          
          moodmn.hbr  = xml.getFloat("hbr");
          moodmn.ecg  = xml.getFloat("ecg");
          
          if (moodmn.getMoodChange()){
            musm.setActiveList(moodmn.getMood());
            musm.nextSong();
          }
        }
      } catch (Exception e) {
        println("Error in XML parse, send the request again! (2)");
        println("Error Ocurred --> "+e);
        updateData();
      }
    }


  }

  public void close () {
    client.clear();
    client.write("exit");
    delay(50);
    client.stop();
  }

}
