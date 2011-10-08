package org.alivepdf.fonts
{
  import flash.utils.Dictionary;
	
  /**
   * This class is a static dictionnary to cache CoreFont object
   * @author Félix Gerzaguet
   * 
   */	
	public final class CoreFontCache
	{		
		private static const dict:Dictionary = new Dictionary();
    
    public static function getFont(fontName:String):CoreFont
    {
      var cachedFont:CoreFont = dict[fontName];
      
      if ( ! cachedFont ) {
        cachedFont = new CoreFont(fontName);
        dict[fontName] = cachedFont;
      }
      
      return cachedFont;
    }
	}
}