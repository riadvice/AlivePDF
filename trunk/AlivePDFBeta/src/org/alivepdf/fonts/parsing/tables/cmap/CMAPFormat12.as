package org.alivepdf.fonts.parsing.tables.cmap
{
	import flash.utils.ByteArray;
	
	/**
	 * Format 12: segmmented coverage.
	 * TODO: implement :-)
	 */
	public class CMAPFormat12 extends CMAPFormat
	{
		
		
		public function CMAPFormat12(format:uint, length:uint, language:uint, data:ByteArray)
		{
			
			super(12, length, language, data);
			
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
			var str:String = '=== CMAPFormat12 ===\n';
			str += '===================\n';
			return str;
		}
	}
}