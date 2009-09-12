package org.alivepdf.fonts.parsing.tables.cmap
{
	import flash.utils.ByteArray;
	
	/**
	 * Format 14: unicode variation sequences.
	 * TODO: implement :-)
	 */
	public class CMAPFormat14 extends CMAPFormat
	{
		
		
		public function CMAPFormat14(format:uint, length:uint, language:uint, data:ByteArray)
		{
			
			super(14, length, language, data);
			
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
			var str:String = '=== CMAPFormat14 ===\n';
			str += '===================\n';
			return str;
		}
	}
}