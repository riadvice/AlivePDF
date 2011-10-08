package org.alivepdf.colors
{
  import flash.utils.Dictionary;
	
  /**
   * This class is a static dictionnary to cache RGBColor objects by hexstring
   * @author Félix Gerzaguet
   * 
   */	
	public final class RGBColorCache
	{		
    
    private static const dict:Dictionary = new Dictionary();
    
    public static function getColor(hex:String):RGBColor
    {
      var cachedColor:RGBColor = dict[hex];
      
      if ( ! cachedColor ) {
        cachedColor = RGBColor.hexStringToRGBColor( hex );
        dict[hex] = cachedColor;
      }
      
      return cachedColor;
    }
    
	}
}