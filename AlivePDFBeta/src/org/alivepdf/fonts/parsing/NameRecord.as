package org.alivepdf.fonts.parsing
{
	
	import flash.utils.ByteArray;
	import org.alivepdf.fonts.parsing.NameID;
	
	public final class NameRecord
	{
		
		public var platformId:int;
		public var encodingId:int;
		public var languageId:int;
		public var nameId:int;
		public var stringLength:int;
		public var stringOffset:int;
		public var record:String;
		
		public function NameRecord( stream:ByteArray)
		{
			platformId = stream.readShort();
			encodingId = stream.readShort();
			languageId = stream.readShort();
			nameId = stream.readShort();
			stringLength = stream.readShort();
			stringOffset = stream.readShort();
			
		}
		
		public function decode( stream:ByteArray ):void
	    {
	        var sb:String = new String();
	        var i:int;
	        stream.position += stringOffset;

	        if (platformId == NameID.platformUnicode)
	        {
	            for (i = 0; i < stringLength/2; i++)
	            	sb += String.fromCharCode(stream.readUnsignedShort());

	        } else if (platformId == NameID.platformMacintosh) 
	        {
	           	sb = stream.readUTFBytes(stringLength);
	            	
	        } else if (platformId == NameID.platformISO) 
	        {
	        	sb = stream.readUTFBytes(stringLength);

	        } else if (platformId == NameID.platformMicrosoft) 
	        {
	            var c:uint;

	            for (i = 0; i < stringLength/2; i++)
	            {
	                c = stream.readUnsignedShort();
	                sb += String.fromCharCode(c);
	            }
	        }
	        record = sb;
	    }
	}
}