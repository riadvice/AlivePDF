package org.alivepdf.fonts.parsing.tables.cmap
{
	/**
	 * 
	 */	
	public class CMAPEncodingRecord {
		private var _platformID:uint;
		private var _encodingID:uint;
		private var _offset:uint;
		
		public function CMAPEncodingRecord(platformID:uint, encodingID:uint, offset:uint)
		{
			this._platformID = platformID;
			this._encodingID = encodingID;
			this._offset = offset;
		}
		
		/**
		 * Platform ID.
		 */
		public function get platformID( ):uint {
			return this._platformID;
		}
		
		/**
		 * Platform-specific encoding ID.
		 */		
		public function get encodingID( ):uint {
			return this._encodingID;
		}
		
		/**
		 * Byte offset from beginning of table to the subtable for this encoding.
		 */
		public function get offset( ):uint {
			return this._offset;
		}
		
		public function toString( ):String {
			return '[CMAPEncodingRecord platformID=' + this._platformID + ' encodingID=' + this._encodingID + ' offset=' + this._offset + ']';
		}
	}
}