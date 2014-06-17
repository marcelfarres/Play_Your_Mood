public class FontMng  {

  String [] fonts = {"STBaoli-SC-Regular-48.vlw"};
  PFont [] fonts_data;

  public FontMng () {
    loadFonts();
  }

  public void loadFonts() {

    // Test diferent fonts.
    // fonts_data = new PFont[18];
    // for (int i = 0; i < 18; ++i) {
    //  println("fonts[i]: "+"fonts/"+fonts[i]);
    //  fonts_data [i] = loadFont("fonts/"+fonts[i]);
    // }
    
    // Defenitive font. 
    fonts_data     = new PFont[1];
    fonts_data [0] = loadFont("fonts/"+fonts[0]);
  }
}