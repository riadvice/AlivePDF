package org.alivepdf.fonts.parsing.tables.cmap
{
	import flash.utils.ByteArray;
	
	/**
	 * Format 0: Byte encoding table.
	 */	
	public class CMAPFormat0 extends CMAPFormat
	{
		private var glyphIDArray:Array;
		
		public function CMAPFormat0(format:uint, length:uint, language:uint, data:ByteArray)
		{
			
			super(0, length, language, data);
			
			// Parse the incoming data.
			this.glyphIDArray = new Array(256);
			for (var i:uint=0; i<256; i++) {
				this.glyphIDArray[i] = data.readUnsignedByte();
			}
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function mapCharCodeToGlyph(charCode:uint):uint {
			// Easy 1-1 mapping up to 256 characters.
			return this.glyphIDArray[charCode];
		}
		
		
		public function toString( ):String {
			var str:String = '=== CMAPFormat0 ===\n';
			for (var i:uint; i<256; i++) {
				str += '\t' + i + '\t' + this.mapCharCodeToGlyph(i) + '\n';
			}
			str += '===================\n';
			return str;
		}
	}
}