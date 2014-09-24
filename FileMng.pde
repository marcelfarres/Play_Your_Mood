public class FileMng  {
  //Read
	JSONArray happy;
	JSONArray sad;
	JSONArray angry; 
	JSONArray relaxed;

	String libPath	 =   "data/songLib.json";

  // Save
  JSONArray full_data;

  String outPath  =    "data/output/";
  String fileName;

	public FileMng () {
    happy     = new JSONArray();
    sad       = new JSONArray();
    angry     = new JSONArray();
    relaxed   = new JSONArray();
    
    readJSON();
    
    full_data = new JSONArray();
	}

	public void readJSON() {
		String tmp;
		
		JSONArray values = loadJSONArray(libPath);
		JSONObject songList = values.getJSONObject(0);
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

	public void saveData2JSON (ArrayList<Data> all_data){

    // afegir id subjecte ?
    String [] p1 = {String.valueOf(day()), String.valueOf(month()), String.valueOf(year())};
    String [] p2 = {String.valueOf(hour()), String.valueOf(minute()), String.valueOf(second())};
    String d1 = join(p1, "-");
    String d2 = join(p2, ":"); 

    fileName = d1 + "_" + d2 +".json"; 

		// Data + Info capcalera
    for (Data o : all_data) {
      JSONObject data = new JSONObject();

      data.setInt("id", full_data.size());
      data.setInt("target", o.target);
      data.setInt("Relaxed", o.m_time[0]);
      data.setInt("Sad", o.m_time[1]);
      data.setInt("Angry", o.m_time[2]);
      data.setInt("Happy", o.m_time[3]);

      full_data.setJSONObject(full_data.size(), data);
    }

    saveJSONArray(full_data, outPath+fileName);
	}

}