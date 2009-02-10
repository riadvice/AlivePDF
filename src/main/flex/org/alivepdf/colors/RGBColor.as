package org.alivepdf.colors
{	
	public final class RGBColor implements Color	
	{
		public var r:Number;
		public var g:Number;
		public var b:Number;
		
		public function RGBColor ( color:Number=0 )	
		{	
			r = (color >> 16) & 0xFF;
			g = (color >> 8) & 0xFF;
			b = color & 0xFF;
		}
		
		public static function hexStringToRGBColor ( hex:String ):RGBColor
		{
		    hex = hex.toLowerCase();

	        var l:int;
	        
		    // Strip "0x"
		    if ( hex.indexOf("0x") > -1 )
		    {
		        l   = hex.length - 2;
		        hex = hex.substr( hex.length - l, l );
		    }

		    if ( hex.indexOf("#") > -1 )
		    {
		        l   = hex.length - 1;
		        hex = hex.substr( hex.length - l, l );
		    }

            // Trim/Extend to correct size 		        
            l = hex.length;
            
            if ( l > 6 )
                hex = hex.substr(0,6);

            var c : Number = parseInt( hex, 16 );

            return new RGBColor( c );
		}		
	}
}