package org.alivepdf.images
{
	
	import flash.utils.ByteArray;

	public final class GIFImage extends PDFImage
	
	{
		
		public function GIFImage(imageStream:ByteArray, id:int)
		
		{
			
			super ( imageStream, id );
			
			f = "LZWDecode";
			
			parseGIF();
			
		}
		
		private function parseGIF ():void 
		
		{
			
			stream.position = 6;
			
			/*
			trace( stream.readUnsignedShort() );
			trace( stream.readUnsignedShort() );
			trace( stream.readUnsignedShort() );
			trace( stream.readUnsignedShort() );*/
			
			ct = 2;
			
			cs = "DeviceRGB";
			
			width = 320;
			height = 311;
			
			parameters = '/DecodeParms <</Predictor 15 /Colors '+(ct == 2 ? 3 : 1)+' /BitsPerComponent '+bpc+' /Columns '+width+'>>';
			
		}
		
	}
	
}