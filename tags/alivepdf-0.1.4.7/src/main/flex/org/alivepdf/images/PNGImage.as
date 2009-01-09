package org.alivepdf.images
{
	import flash.utils.ByteArray;

	// dirty class to be cleaned
	public final class PNGImage extends PDFImage
	{
		
		private var palBytes:ByteArray;
		private var idataBytes:ByteArray;
		private var type:String;
		
		public function PNGImage ( imageStream:ByteArray, id:int )
		{
			super ( imageStream, id );
						
			f = "FlateDecode";
			
			parsePNG();
		}
		
		private function parsePNG ():Boolean
		{
			
			palBytes = new ByteArray();
			idataBytes = new ByteArray();
			
			stream.position = 0;
			
			stream.readUnsignedInt();
			stream.readUnsignedInt();

			stream.readUnsignedInt();
			stream.readUnsignedInt();
			
			width = stream.readInt();
			height = stream.readInt();

			bpc = stream.readByte();
			
			ct = stream.readByte();
			
			if(ct==0) cs =' DeviceGray';
			else if(ct==2) cs = 'DeviceRGB';
			else if(ct==3) cs = 'Indexed';
			else throw new Error ("Alpha channel not supported");
			
			if ( stream.readByte() != 0 ) throw new Error ("Unknown compression method");
			if ( stream.readByte() != 0 ) throw new Error ("Unknown filter method");
			if ( stream.readByte() != 0 ) throw new Error ("Interlacing not supported");
			
			stream.readUnsignedInt();
			
			parameters = '/DecodeParms <</Predictor 15 /Colors '+(ct == 2 ? 3 : 1)+' /BitsPerComponent '+bpc+' /Columns '+width+'>>';
			
			var trns:String ='';
			
			do 
			{
			
				n = stream.readInt();
				type = stream.readUTFBytes(4);
				
				if ( type == 'PLTE' )
				{
					
					stream.readBytes(palBytes, stream.position, n);
					stream.readUnsignedInt();
					palBytes.position = 0;
					pal = palBytes.readUTFBytes(palBytes.bytesAvailable);
					
				} else if ( type == "tRNS" )
				{
					
					
				} else if ( type == "IDAT" )
				{
					
					stream.readBytes(idataBytes, idataBytes.length, n);
					stream.readUnsignedInt();
					
				} else if ( type == "IEND" )
				{
					
					break;
					
				} else stream.position += n + 4;
				
			} while ( n > 0 );
			
			if ( cs == "Indexed" && !pal.length ) throw new Error ("Missing palette in current picture");
			
			return !(stream.position = 0);
			
		}
		
		public override function get bytes():ByteArray
	    {
	    	return idataBytes;	
	    }
	}
}