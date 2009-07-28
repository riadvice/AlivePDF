package org.alivepdf.fonts.parsing.tables.cmap
{
	import flash.utils.ByteArray;
	
	/**
	 * Format 10: trimmed array.
	 * TODO: implement :-)
	 */
	public class CMAPFormat10 extends CMAPFormat
	{
		
		
		public function CMAPFormat10(format:uint, length:uint, language:uint, data:ByteArray)
		{
			
			super(10, length, language, data);
			
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
			var str:String = '=== CMAPFormat10 ===\n';
			str += '===================\n';
			return str;
		}
	}
}