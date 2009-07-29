package org.alivepdf.images
{
	import flash.utils.ByteArray;
	
	import org.alivepdf.decoding.Filter;

	public class PNGImage extends PDFImage
	{
		protected var idataBytes:ByteArray;
		private var palBytes:ByteArray;
		private var type:int;
		public static const HEADER:int = 0x8950;
		public static const PLTE:int = 0x504C5445;
		public static const TRNS:int = 0x74524E53;
		public static const IDAT:int = 0x49444154;
		public static const IEND:int = 0x49454E44;
		
		public function PNGImage ( imageStream:ByteArray, colorSpace:String, id:int )
		{
			super ( imageStream, colorSpace, id );
			filter = Filter.FLATE_DECODE;
		}
		
		protected override function parse ():void
		{
			palBytes = new ByteArray();
			idataBytes = new ByteArray();
			
			stream.position = 16;
			
			width = stream.readInt();
			height = stream.readInt();

			bitsPerComponent = stream.readByte();
			
			ct = stream.readByte();
			
			if(ct==0) colorSpace = ColorSpace.DEVICE_GRAY;
			else if(ct==2) colorSpace = ColorSpace.DEVICE_RGB;
			else if(ct==3) colorSpace = ColorSpace.INDEXED;
			else throw new Error("Alpha channel not supported for now");
			
			if ( stream.readByte() != 0 ) throw new Error ("Unknown compression method");
			if ( stream.readByte() != 0 ) throw new Error ("Unknown filter method");
			if ( stream.readByte() != 0 ) throw new Error ("Interlacing not supported");
			
			stream.position += 4;
			
			parameters = '/DecodeParms <</Predictor 15 /Colors '+(ct == 2 ? 3 : 1)+' /BitsPerComponent '+bitsPerComponent+' /Columns '+width+'>>';
			
			var trns:String ='';
			
			do 
			{	
				n = stream.readInt();
				type = stream.readUnsignedInt();
				
				if ( type == PNGImage.PLTE )
				{
					stream.readBytes(palBytes, stream.position, n);
					stream.readUnsignedInt();
					palBytes.position = 0;
					pal = palBytes.readUTFBytes(palBytes.bytesAvailable);
					
				} else if ( type == PNGImage.TRNS )
				{
					
				} else if ( type == PNGImage.IDAT )
				{	
					stream.readBytes(idataBytes, idataBytes.length, n);
					stream.readUnsignedInt();
					
				} else if ( type == PNGImage.IEND )
				{	
					break;
					
				} else stream.position += n+4;
				
			} while ( n > 0 );
			
			if ( colorSpace == ColorSpace.INDEXED && !pal.length ) throw new Error ("Missing palette in current picture");
		}
		
		public override function get bytes():ByteArray
	    {	
	    	return idataBytes;	
	    }
	}
}