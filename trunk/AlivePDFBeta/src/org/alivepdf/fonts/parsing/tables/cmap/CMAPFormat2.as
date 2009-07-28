package org.alivepdf.fonts.parsing.tables.cmap
{
	import flash.utils.ByteArray;
	
	/**
	 * Format 2: high-byte mapping through table.
	 * TODO: implement :-)
	 */
	public class CMAPFormat2 extends CMAPFormat
	{
		private var glyphIdArray:Array;
		
		public function CMAPFormat2(format:uint, length:uint, language:uint, data:ByteArray)
		{
			
			super(format, length, language, data);
		}

	}
}