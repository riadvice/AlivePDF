package org.alivepdf.fonts.parsing.tables.cmap
{
	import flash.utils.ByteArray;
	
	/**
	 * Format 6: Trimmed table mapping.
	 */
	public class CMAPFormat6 extends CMAPFormat
	{
		private var _firstCode:uint;
		private var _entryCount:uint;
		private var glyphIDArray:Array;
		
		public function CMAPFormat6(format:uint, length:uint, language:uint, data:ByteArray)
		{
			super(6, length, language, data);
			
			// Parse the incoming data.
			this._firstCode = data.readUnsignedShort();
			this._entryCount = data.readUnsignedShort();
			
			// Read data for each entry.
			this.glyphIDArray = new Array(this._entryCount);
			for (var i:uint=0; i<this._entryCount; i++)
				this.glyphIDArray[i] = data.readUnsignedShort();
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function mapCharCodeToGlyph(charCode:uint):uint
		{	
			// If the given charCode lies in the range of firstCode to firstCode+entryCount
			// (...)
			if (charCode >= this._firstCode && charCode < this._entryCount + this._firstCode)
			{
				return this.glyphIDArray[charCode - this._firstCode];
			}
			else {
				return 0;
			}
		}
		
		public function toString( ):String
		{
			var str:String = '=== CMAPFormat6 ===\n';
			str += 'firstCode:\t' + this._firstCode + '\n';
			str += 'entryCount:\t' + this._entryCount + '\n';
			str += 'charCode/glyphIndex table:\n';
			for (var i:uint=0; i<this._entryCount; i++) {
				str += '  ' + i + '\t' + this.mapCharCodeToGlyph(i) + '\n';
			}
			str += '===================\n';
			return str;
		}
	}
}