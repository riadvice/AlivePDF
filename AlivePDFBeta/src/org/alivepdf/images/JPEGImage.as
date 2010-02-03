package org.alivepdf.images
{
	import flash.utils.ByteArray;
	
	import org.alivepdf.decoding.Filter;
	
	public class JPEGImage extends PDFImage
	{
		protected var format:int;
		protected var physicalWidthDpi:int;
		protected var physicalHeightDpi:int;
		
		public static const FORMAT:int = 0;
		public static const HEADER:int = 0xFFD8;
		
		public function JPEGImage( imageStream:ByteArray, colorSpace:String, id:int )
		{
			super ( imageStream, colorSpace, id );
			_filter = Filter.DCT_DECODE;
		}
		
		protected override function parse ():void
		{	
			var data:ByteArray = new ByteArray();
			var marker:int;
			var size:int;
			var appID:ByteArray = new ByteArray();
			appID.writeByte(0x4A);
			appID.writeByte(0x46);
			appID.writeByte(0x49);
			appID.writeByte(0x46);
			appID.writeByte(0x00);
			var x:int;
			var y:int;
			
			while ( true )
			{
				if ( read ( data, 0, 4 ) != 4 ) 
					return;
				
				marker = getShortBigEndian(data,0);
				size = getShortBigEndian(data,2);
				
				if ( (marker & 0xFF00) != 0xFF00 ) 
					return;
				
				if ( marker == 0xFFE0 )
				{
					if ( size < 14 ) return;
					
					if ( read ( data, 0, 12 ) != 12 ) 
						return;
					
					if ( equals( appID, 0, data, 0, 5 ) )
					{	
						if ( data[7] == 1 )
						{
							physicalWidthDpi = getShortBigEndian(data, 8);
							physicalHeightDpi = getShortBigEndian(data, 10);
							if ( (data[12] & 0xFF) == 1) 
								colorSpace = ColorSpace.DEVICE_GRAY;
							
						} else if ( data[7] == 2 )
						{	
							x = getShortBigEndian(data, 8);
							y = getShortBigEndian(data, 10);
							
							if ( (data[12] & 0xFF) == 1) 
								colorSpace = ColorSpace.DEVICE_GRAY;
							
							physicalWidthDpi = int ( x * 2.54 );
							physicalHeightDpi = int ( y * 2.54 );	
						}
					}
					
					stream.position += size - 14;
					
				} else if ( marker >= 0xFFC0 && marker <= 0xFFCF && marker != 0xFFC4 && marker != 0xFFC8 )
				{
					if ( read ( data, 0, 6 ) != 6 ) 
						return;
					
					format = JPEGImage.FORMAT;
					bitsPerComponent = (colorSpace != ColorSpace.DEVICE_RGB) ? 8 : ( data[0] & 0xFF ) * ( data[5] & 0xFF ) / 3;
					progressive = marker == 0xFFC2 || marker == 0xFFC6 || marker == 0xFFCA || marker == 0xFFCE;
					
					_width = getShortBigEndian(data, 3);
					_height = getShortBigEndian(data, 1);
					
					if ( (data[5] & 0xFF) == 1) 
						colorSpace = ColorSpace.DEVICE_GRAY;
					
				} else stream.position += size - 2;	
			}
		}
		
		private function read ( dest:ByteArray, offset:int, num:int ):int
		{
			stream.readBytes( dest, offset, num );
			return num;	
		}
		
		private static function equals ( a1:ByteArray, offs1:int, a2:ByteArray, offs2:int, num:int ):Boolean
		{	
			while ( num-- > 0 )
				if ( a1[offs1++] != a2[offs2++] ) 
					return false;	
			return true;
		}
		
		private function getShortBigEndian ( a:ByteArray, offs:int ):int
		{
			return (a[offs] & 0xFF) << 8 | (a[offs+1] & 0xFF);	
		}
	}
}