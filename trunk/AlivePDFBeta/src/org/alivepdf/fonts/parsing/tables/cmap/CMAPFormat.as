package org.alivepdf.fonts.parsing.tables.cmap
{
	import flash.utils.ByteArray;
	
	public class CMAPFormat
	{
		protected var _format:uint;
		protected var _length:uint;
		protected var _language:uint;
		
		public function CMAPFormat(type:uint, length:uint, language:uint, data:ByteArray)
		{
			this._format = type;
			this._length = length;
			this._language = language;
		}
		
		
		/**
		 * Maps a given character code to a glyph index.
		 * 
		 * @param charCode The character code to map.
		 * @return The glyph index for the given character code. 0 means the glyph is missing.
		 * 
		 */		
		public function mapCharCodeToGlyph(charCode:uint):uint
		{
			trace('mapCharCodeToGlyph not implemented')
			return 0;
		}
		
		
		/**
		 * @return The format type.
		 */		
		public function get format( ):uint
		{
			return this._format;
		}
		
		
		/**
		 * @return The length of bytes in this format/subTable.
		 */		
		public function get length( ):uint
		{
			return this._length;
		}
		
		
		/** 
		 * This ID should be 0 for cmap tables whose platform IDs are other than Macintosh (platform ID 1). For
		 * cmap subtables whose platform IDs are Macintosh, set this field to the Macintosh language ID of the
		 * cmap subtable plus one, or to zero if the cmap subtable is not language-specific. For example, a Mac OS
		 * Turkish cmap subtable must set this field to 18, since the Macintosh language ID for Turkish is 17.
		 * A Mac OS Roman cmap subtable must set this field to 0, since Mac OS Roman is not a language-specific encoding.
		 * 
		 * @return The language ID for this format.
		 * @see http://www.microsoft.com/typography/otspec/cmap.htm#language
		 */		
		public function get language( ):uint
		{
			return this._language;
		}
	}
}