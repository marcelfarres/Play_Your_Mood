public class FileMng  {

  JSONArray happy;
  JSONArray sad;
  JSONArray angry; 
  JSONArray relaxed;

  String libPath   =   "data/songLib.json";

  public FileMng () {
    happy   = new JSONArray();
    sad     = new JSONArray();
    angry   = new JSONArray();
    relaxed = new JSONArray();

    readJSON();
  }

  public void readJSON() {
    String tmp;
    
    JSONArray values = loadJSONArray(libPath);
    JSONObject songList = values.getJSONObject(0);
    println("values: "+values);
      for (int i = 0; i < songList.size(); ++i) {

        JSONObject song = songList.getJSONObject(str(i));
        tmp = song.getString("mood");

        if ( tmp.equals("Happy") ) {
          happy.setJSONObject( happy.size(), song );
        }
        if ( tmp.equals("Sad")  ){
          sad.setJSONObject( sad.size(), song );
        }
        if ( tmp.equals("Angry") ) {
          angry.setJSONObject( angry.size(), song );
        }
        if ( tmp.equals("Relaxed") ) {
          relaxed.setJSONObject( relaxed.size(), song );
        }
        
      }
    println("Happy size: "+happy.size());
    println("Sad size: "+sad.size());
    println("Angry size: "+angry.size());
    println("Relaxed size: "+relaxed.size());
    
  }

}
