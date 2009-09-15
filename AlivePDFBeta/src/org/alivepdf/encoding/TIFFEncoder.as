package org.alivepdf.encoding
{
	import flash.display.BitmapData;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	// http://local.wasp.uwa.edu.au/~pbourke/dataformats/tiff/	
	
	public class TIFFEncoder
	{
		public function TIFFEncoder() {;}
		
		static public function encode( bmp:BitmapData ):ByteArray
		{
			var header:ByteArray = new ByteArray();
			var img:ByteArray = new ByteArray();			
			var ifd:ByteArray = new ByteArray();
			var picture:ByteArray = new ByteArray();
			var blue:Number = 0;
			var green:Number = 0;
			var pixel:Number = 0;
			var red:Number = 0;
			
			header.endian = Endian.LITTLE_ENDIAN;
			header.writeByte( 73 ); // Byte significance
			header.writeByte( 73 );
			header.writeShort( 42 ); // TIFF identifier
			header.writeInt( 8 ); // Where to find IFD
			
			ifd.endian = Endian.LITTLE_ENDIAN;
			ifd.writeShort( 12 ); // Markers
			
			// Image width
			ifd.writeShort( 256 ); // IFD Type
			ifd.writeShort( 3 ); // Data Type
			ifd.writeInt( 1 ); // Number of values
			ifd.writeInt( bmp.width ); // Value

			// Image length	(height)			
			ifd.writeShort( 257 ); // IFD Type
			ifd.writeShort( 3 ); // Data Type
			ifd.writeInt( 1 ); // Number of values
			ifd.writeInt( bmp.height ); // Value				
			
			// Bits per sample			
			// Three bytes found at this offset
			ifd.writeShort( 258 ); // IFD Type
			ifd.writeShort( 3 ); // Data Type
			ifd.writeInt( 3 ); // Number of values
			ifd.writeInt( 158 ); // Value
			
			// Compression			
			ifd.writeShort( 259 ); // IFD Type
			ifd.writeShort( 3 ); // Data Type
			ifd.writeInt( 1 ); // Number of values
			ifd.writeInt( 1 ); // Value												
			
			// Photometric interpretation			
			ifd.writeShort( 262 ); // IFD Type
			ifd.writeShort( 3 ); // Data Type
			ifd.writeInt( 1 ); // Number of values
			ifd.writeInt( 2 ); // Value
			
			// Strip offsets			
			// Where image data starts
			ifd.writeShort( 273 ); // IFD Type
			ifd.writeShort( 4 ); // Data Type
			ifd.writeInt( 1 ); // Number of values
			ifd.writeInt( 180 ); // Value																		
			
			// Samples per pixel			
			ifd.writeShort( 277 ); // IFD Type
			ifd.writeShort( 4 ); // Data Type
			ifd.writeInt( 1 ); // Number of values
			ifd.writeInt( 3 ); // Value																								
			
			// Rows per strip			
			ifd.writeShort( 278 ); // IFD Type
			ifd.writeShort( 3 ); // Data Type
			ifd.writeInt( 1 ); // Number of values
			ifd.writeInt( bmp.height ); // Value																											
			
			// Strip byte counts			
			ifd.writeShort( 279 ); // IFD Type
			ifd.writeShort( 4 ); // Data Type
			ifd.writeInt( 1 ); // Number of values
			ifd.writeInt( bmp.width * bmp.height * 3 ); // Value																													
			
			// X resolution		
			// Two long values found at this offset	
			ifd.writeShort( 282 ); // IFD Type
			ifd.writeShort( 5 ); // Data Type
			ifd.writeInt( 1 ); // Number of values
			ifd.writeInt( 164 ); // Value																		
			
			// Y resolution	
			// Two long values found at this offset		
			ifd.writeShort( 283 ); // IFD Type
			ifd.writeShort( 5 ); // Data Type
			ifd.writeInt( 1 ); // Number of values
			ifd.writeInt( 172 ); // Value																										
			
			// Resolution unit			
			ifd.writeShort( 296 ); // IFD Type
			ifd.writeShort( 3 ); // Data Type
			ifd.writeInt( 1 ); // Number of values
			ifd.writeInt( 2 ); // Value							

			// Close off IFD
			ifd.writeInt( 0 );

			// Bits per sample
			// Array of three values (R, G, B)
			ifd.writeShort( 8 );
			ifd.writeShort( 8 );
			ifd.writeShort( 8 );
			
			// X resolution
			// Actual rational value (two longs)
			// Numerator first, then denominator
			ifd.writeInt( 720000 );
			ifd.writeInt( 10000 );
			
			// Y resolution
			// Actual rational value (two longs)
			// Numerator first, then denominator
			ifd.writeInt( 720000 );
			ifd.writeInt( 10000 );

			// Picture data
			for( var h:Number = 0; h < bmp.height; h++ )
			{
				for( var w:Number = 0; w < bmp.width; w++ )
				{
					pixel = bmp.getPixel( w, h );
		 
					red = ( pixel & 0xFF0000 ) >>> 16;
					green = ( pixel & 0x00FF00 ) >>> 8;
					blue = pixel & 0x0000FF;					
					
					picture.writeByte( red ); // Red
					picture.writeByte( green );   // Green
					picture.writeByte( blue );   // Blue
				}	
			}		
			
			img.writeBytes( header );
			img.writeBytes( ifd );
			img.writeBytes( picture );
			
			return img;	
		}
	}
}