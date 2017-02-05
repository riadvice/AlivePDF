/**
* PNG encoding class from kaourantin.net, optimised by 5etdemi.com/blog
* AlivePDF modification : encode() method has been modified to return only the needed IDAT chunk for AlivePDF.
* @author kaourantin
* @version 0.1
*/

package org.alivepdf.encoding
{
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	
	public final class PNGEncoder
	{
	
		/**
		 * Allows you to encode a BitmapData to a PNG stream for AlivePDF. 
		 * @param image The BitmapData to encode
		 * @param transparent Specify if the PNG is transparent or not. The value of this parameter is false by default.
		 * @return 
		 * 
		 */		
	    public static function encode(image:BitmapData, transparent:Boolean=false):ByteArray
	    {
	        // Build IDAT chunk
	        var IDAT:ByteArray = new ByteArray();
	        
	        if (transparent)
				writeRaw(image, IDAT);
			else writeSub(image, IDAT);
	        
	        IDAT.compress();
	        return IDAT;
	    }
	    
	    private static function writeRaw(img:BitmapData, IDAT:ByteArray):void
	    {
	        var h:int = img.height;
	        var w:int = img.width;
	        var transparent:Boolean = img.transparent;
	        var subImage:ByteArray;
			var rectangle:Rectangle = new Rectangle(0, 0, w, 1)
	        
	        for(var i:int=0;i < h;i++)
			{
	            // no filter
	            if ( !transparent )
				{
					rectangle.y = i;
	            	subImage = img.getPixels(rectangle);
	            	//Here we overwrite the alpha value of the first pixel
	            	//to be the filter 0 flag
	            	subImage[0] = 0;
					IDAT.writeBytes(subImage);
					//And we add a byte at the end to wrap the alpha values
					IDAT.writeByte(0xff);
	            } else 
				{
	            	IDAT.writeByte(0);
	            	var p:uint;
	                for(var j:int=0;j < w;j++)
					{
	                    p = img.getPixel32(j,i);
	                    IDAT.writeUnsignedInt( uint(((p&0xFFFFFF) << 8)| (p>>>24)));
	                }
	            }
	        }
	    }
	    
	    private static function writeSub(image:BitmapData, IDAT:ByteArray):void
	    {
            var r1:uint;
            var g1:uint;
            var b1:uint;
            var a1:uint;
            
            var r2:uint;
            var g2:uint;
            var b2:uint;
            var a2:uint;
            
            var r3:uint;
            var g3:uint;
            var b3:uint;
            var a3:uint;
            
            var p:uint;
	        var h:int = image.height;
	        var w:int = image.width;
	        
	        for(var i:int=0;i < h;i++)
			{
	            // no filter
	            IDAT.writeByte(1);
				
	            if ( !image.transparent )
				{
					r1 = 0;
					g1 = 0;
					b1 = 0;
					a1 = 0xff;
					
	                for(var j:int=0;j < w;j++)
					{
	                    p = image.getPixel(j,i);
	                    
	                    r2 = p >> 16 & 0xff;
	                    g2 = p >> 8  & 0xff;
	                    b2 = p & 0xff;
	                    
	                    r3 = (r2 - r1 + 256) & 0xff;
	                    g3 = (g2 - g1 + 256) & 0xff;
	                    b3 = (b2 - b1 + 256) & 0xff;
	                    
	                    IDAT.writeByte(r3);
	                    IDAT.writeByte(g3);
	                    IDAT.writeByte(b3);
	                    
	                    r1 = r2;
	                    g1 = g2;
	                    b1 = b2;
	                    a1 = 0;
	                }
	            } else
				{
					r1 = 0;
					g1 = 0;
					b1 = 0;
					a1 = 0;
					
	                for(var k:int=0;k < w;k++)
					{
	                    p = image.getPixel32(k,i);
	                    
	                    a2 = p >> 24 & 0xff;
	                    r2 = p >> 16 & 0xff;
	                    g2 = p >> 8  & 0xff;
	                    b2 = p & 0xff;
	                    
	                    r3 = (r2 - r1 + 256) & 0xff;
	                    g3 = (g2 - g1 + 256) & 0xff;
	                    b3 = (b2 - b1 + 256) & 0xff;
	                    a3 = (a2 - a1 + 256) & 0xff;
	                    
	                    IDAT.writeByte(r3);
	                    IDAT.writeByte(g3);
	                    IDAT.writeByte(b3);
	                    IDAT.writeByte(a3);
	                    
	                    r1 = r2;
	                    g1 = g2;
	                    b1 = b2;
	                    a1 = a2;
	                }
	            }
	        }
	    }
	}
}