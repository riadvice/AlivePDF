package org.alivepdf.fonts.parsing.tables.cmap
{
	import flash.utils.ByteArray;
	
	/**
	 * Format 8: mixed 16-bit and 32-bit coverage.
	 * TODO: implement :-)
	 */
	public class CMAPFormat8 extends CMAPFormat
	{
		
		
		public function CMAPFormat8(format:uint, length:uint, language:uint, data:ByteArray)
		{
			
			super(8, length, language, data);
			
			// Parse the incoming data.
			
			trace(this)
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function mapCharCodeToGlyph(charCode:uint):uint {
			
			return 0;
		}
		
		
		public function toString( ):String {
			var str:String = '=== CMAPFormat8 ===\n';
			str += '===================\n';
			return str;
		}
	}
}