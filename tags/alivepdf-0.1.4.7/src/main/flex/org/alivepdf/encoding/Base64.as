package org.alivepdf.encoding 
{
	
	/*
	*	A Base64 encoder/decoder implementation in Actionscript 3
	*   from subhero@gmail.com
	*/
	
	import flash.utils.ByteArray;
	
	public class Base64 {
		
		private static var lineBreak:Boolean;
		
		private static var _b64Chars:Array = new Array(
		
			'A','B','C','D','E','F','G','H',
			'I','J','K','L','M','N','O','P',
			'Q','R','S','T','U','V','W','X',
			'Y','Z','a','b','c','d','e','f',
			'g','h','i','j','k','l','m','n',
			'o','p','q','r','s','t','u','v',
			'w','x','y','z','0','1','2','3',
			'4','5','6','7','8','9','+','/'
			
		)
		
		/*
		takes a byteArray as input and return the base64 string
		*/
		
		private static var lookupObject:Object = buildLookUpObject();
		
		private static function buildLookUpObject ():Object
		
		{
			
			var obj:Object = new Object();
			
			for (var i:int = 0; i< _b64Chars.length; i++ ) obj[_b64Chars[i]] = i;
			
			return obj;
			
		}
		
		public static function encode64String ( pString:String ):String
		
		{
			
			var bBytes:ByteArray = new ByteArray;
			
			bBytes.writeUTFBytes ( pString );
			
			return _encodeBytes ( bBytes );
			
		}
		
		public static function encode64	(pByteArray:ByteArray, pLineBreak:Boolean=true ):String {
			
			lineBreak = pLineBreak;
			
			return _encodeBytes ( pByteArray );
			
		}
		
		private static function _encodeBytes ( pByteArray:ByteArray ):String {
			
			var output:String = '';
			var bufferSize:int;
			pByteArray.position = 0;
			var col:int = 0;
			
			while ( bufferSize = pByteArray.bytesAvailable ) {
				
				bufferSize = Math.min ( 3, bufferSize );
				
				var bytePacket:ByteArray = new ByteArray();
				
				pByteArray.readBytes ( bytePacket, 0, bufferSize );
				
				output += _encodeBytePacket ( bytePacket );
				
				col += 4;
				
				if ( lineBreak &&  ( col % 76 ) == 0 ) {
					
					output += '\n';
					col = 0;
					
				}
				
			}
			
			return output;
			
		}
		
		private static function _encodeBytePacket ( pByteArrayPacket:ByteArray ):String {
			
			var encodedString:String = '';
			var packetLength:uint = pByteArrayPacket.length;
			
			encodedString += _b64Chars[pByteArrayPacket[0] >> 2];
			
			if ( packetLength == 1 ) {
				
				encodedString +=( _b64Chars[((pByteArrayPacket[0] << 4) & 0x3F)] );
				encodedString += ("=="); 
				
			} else if ( packetLength == 2 ) {
				
				encodedString += ( _b64Chars[(pByteArrayPacket[0] << 4) & 0x3F | pByteArrayPacket[1] >> 4 ] );
				encodedString += ( _b64Chars[(pByteArrayPacket[1] << 2) & 0x3F ] );
				encodedString += ("=");		
				
			} else {
				
				encodedString +=( _b64Chars[(pByteArrayPacket[0] << 4) & 0x3F | pByteArrayPacket[1] >> 4 ] );
				encodedString +=( _b64Chars[(pByteArrayPacket[1] << 2) & 0x3F | pByteArrayPacket[2] >> 6 ] );
				encodedString +=( _b64Chars[pByteArrayPacket[2] & 0x3F] );
				
			}
			
			return encodedString;
			
		}
		
		public static function decode64 ( pString:String ):ByteArray
		
		{
			
			return _decodeString ( pString ); 
			
		}
		
		private static function _decodeString ( pString:String ):ByteArray 
		
		{
			
			var sourceString:String = pString;
			var base64Bytes:ByteArray = new ByteArray();
			var stringPacket:String = ""; 
			var lng:int = sourceString.length;
			
			for (var i:int = 0; i< lng; i++ ) {
				
				stringPacket += sourceString.charAt ( i );
				
				if ( stringPacket.length == 4 ) {
					
					base64Bytes.writeBytes ( _decodeStringPacket ( stringPacket ) );
					
					stringPacket = "";
					
				}
				
			}
			
			return base64Bytes;
			
		}
		
		private static function _decodeStringPacket ( stringBuffer:String ):ByteArray
		
		{
			
			var byteStringPacket:ByteArray = new ByteArray();
			
			var charValue1:uint = Base64.lookupObject[stringBuffer.charAt ( 0 )];
			var charValue2:uint = Base64.lookupObject[stringBuffer.charAt ( 1 )];
			var charValue3:uint = Base64.lookupObject[stringBuffer.charAt ( 2 )];
			var charValue4:uint = Base64.lookupObject[stringBuffer.charAt ( 3 )];
			
			byteStringPacket.writeByte(charValue1 << 2 | charValue2 >> 4);
			if (stringBuffer.charAt(2) != "=") byteStringPacket.writeByte(charValue2 << 4 | charValue3 >> 2);
			if (stringBuffer.charAt(3) != "=") byteStringPacket.writeByte(charValue3 << 6 | charValue4);
			
			return byteStringPacket;
			
		}
		
	}
}