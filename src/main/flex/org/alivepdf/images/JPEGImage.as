package org.alivepdf.images
{
	import flash.utils.ByteArray;
	
	// dirty class to be cleaned
	public final class JPEGImage extends PDFImage
	{
		private var format:int;
		private var physicalWidthDpi:int;
		private var physicalHeightDpi:int;
		
		public static var FORMAT_JPEG:int = 0;
		private static const JPG_HEADER:int = 0xFFD8;
		private static const PNG_HEADER:int = 0x8950;
		
		public function JPEGImage( imageStream:ByteArray, id:int )
		{
			super ( imageStream, id );
			
			f = "DCTDecode";
			
			parseJPG();
		}
		
		private function parseJPG ():Boolean
		{
			var data:ByteArray = new ByteArray();
			var marker:int;
			var size:int;
			var APP0_ID:ByteArray = new ByteArray();
			APP0_ID.writeByte(0x4A);
			APP0_ID.writeByte(0x46);
			APP0_ID.writeByte(0x49);
			APP0_ID.writeByte(0x46);
			APP0_ID.writeByte(0x00);
			var x:int;
			var y:int;
			
			while ( true )
			{
				if ( read ( data, 0, 4 ) != 4 ) return false;
				
				marker = getShortBigEndian(data,0);
				size = getShortBigEndian(data,2);
				
				if ( (marker & 0xFF00) != 0xFF00 ) return false;
				
				if ( marker == 0xFFE0 )		
				{
					if ( size < 14 ) return false;
					
					if ( read ( data, 0, 12 ) != 12 ) return false;
					
					if ( equals( APP0_ID, 0, data, 0, 5 ) )
					{
						if ( data[7] == 1 )
						{
							
							physicalWidthDpi = getShortBigEndian(data, 8);
							physicalHeightDpi = getShortBigEndian(data, 10);
							
						} else if ( data[7] == 2 )
						{	
							x = getShortBigEndian(data, 8);
							y = getShortBigEndian(data, 10);
							
							physicalWidthDpi = int ( x * 2.54 );
							physicalHeightDpi = int ( y * 2.54 );	
						}
					}
					
					stream.position += size - 14;
					
				} else if ( marker >= 0xFFC0 && marker <= 0xFFCF && marker != 0xFFC4 && marker != 0xFFC8 )
				{
					if ( read ( data, 0, 6 ) != 6 ) return false;
					
					format = JPEGImage.FORMAT_JPEG;
					bpc = ( data[0] & 0xFF ) * ( data[5] & 0xFF ) / 3;
					progressive = marker == 0xFFC2 || marker == 0xFFC6 || marker == 0xFFCA || marker == 0xFFCE;
					
					width = getShortBigEndian(data, 3);
					height = getShortBigEndian(data, 1);
					
					return true;
					
				} else stream.position += size - 2;
			}
			return true;
		}
		
		private function read ( dest:ByteArray, offset:int, num:int ):int
		{
			stream.readBytes( dest, offset, num );
			return num;	
		}
		
		private static function equals ( a1:ByteArray, offs1:int, a2:ByteArray, offs2:int, num:int ):Boolean
		{	
			while ( num-- > 0 )	
			{
				if ( a1[offs1++] != a2[offs2++] ) return false;	
			}
			return true;
		}
		
		private function getShortBigEndian ( a:ByteArray, offs:int ):int
		{
			return (a[offs] & 0xFF) << 8 | (a[offs+1] & 0xFF);		
		}
	}
}