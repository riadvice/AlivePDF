package org.alivepdf.fonts.parsing.tables
{
	import flash.utils.ByteArray;
	
	import org.alivepdf.fonts.parsing.tables.cmap.CMAPEncodingRecord;
	import org.alivepdf.fonts.parsing.tables.cmap.CMAPFormat;
	import org.alivepdf.fonts.parsing.tables.cmap.CMAPFormat0;
	import org.alivepdf.fonts.parsing.tables.cmap.CMAPFormat10;
	import org.alivepdf.fonts.parsing.tables.cmap.CMAPFormat12;
	import org.alivepdf.fonts.parsing.tables.cmap.CMAPFormat14;
	import org.alivepdf.fonts.parsing.tables.cmap.CMAPFormat2;
	import org.alivepdf.fonts.parsing.tables.cmap.CMAPFormat4;
	import org.alivepdf.fonts.parsing.tables.cmap.CMAPFormat6;
	import org.alivepdf.fonts.parsing.tables.cmap.CMAPFormat8;
	
	/**
	 * A CMAP table as described in <a href="http://www.microsoft.com/typography/otspec/cmap.htm">The OpenType Font File</a>.
	 * TODO: deal with double formats.
	 */	
	public class CMAPTable
	{
		private var _version:uint;	
		private var _numTables:uint;
		
		/**
		 * Array of encoding records.
		 */		
		private var encodingRecords:Array/* of CMAPEncodingRecord */;
		private var subTables:Array = [];
		
		public function CMAPTable(data:ByteArray)
		{	
			trace('*\tParsing CMAPTable');
			
			// Store the initial position in the table.
			var offset:uint = data.position;
			
			// Parse the incoming data.
			this._version = data.readUnsignedShort();
			this._numTables = data.readUnsignedShort();
			
			this.encodingRecords = new Array(this._numTables);
			
			// Read all encoding records and order them by their offset.
			for (var i:uint=0; i<this._numTables; i++) {
				this.encodingRecords[i] = new CMAPEncodingRecord(data.readUnsignedShort(), data.readUnsignedShort(), data.readInt());
			}
			
			// Do we need to sort?
			this.encodingRecords.sortOn('offset', Array.NUMERIC);
			
			// Read all formats.
			for (i=0; i<this._numTables; i++) {
				var encodingRecord:CMAPEncodingRecord = CMAPEncodingRecord(this.encodingRecords[i]);
				data.position = offset + encodingRecord.offset;
				
				// Read the format type and add the corresponding format to our subtables.
				var formatCode:uint = data.readUnsignedShort();
				this.addFormat(i, formatCode, data);
			}
			trace('*\t Done parsing CMAPTable');
		}
		
		
		/**
		 * Creates and adds a CMAPFormat to our subtables.
		 * @param type The type of format.
		 * @param data The data for the format.
		 * 
		 */		
		private function addFormat(index:uint, type:uint, data:ByteArray):void
		{	
			// Determine the correct format class from the given type.
			var formatClass:Class;
			switch (type) {
				case 0 : formatClass = CMAPFormat0; break;
				case 2 : formatClass = CMAPFormat2; break;
				case 4 : formatClass = CMAPFormat4; break;
				case 6 : formatClass = CMAPFormat6; break;
				case 8 : formatClass = CMAPFormat8; break;
				case 10 : formatClass = CMAPFormat10; break;
				case 12 : formatClass = CMAPFormat12; break;
				case 14 : formatClass = CMAPFormat14; break;
				default : {
					// Unknow or unsupported format. Throw error?
					trace('Unknown or unsupported format (' + type + ')')
					break;
				}
			}
			
			if (formatClass) {
				// Create a new format and add it as a subtable.
				this.subTables[index] = new formatClass(type, data.readUnsignedShort(), data.readUnsignedShort(), data);
			}
		}
		
		
		/**
		 * Returns the CMAPFormat for the given platformID and encodingID.
		 * @param platformID
		 * @param encodingID
		 * @return 
		 * 
		 */		
		public function getFormat(platformID:uint, encodingID:uint):CMAPFormat
		{	
			// Loop through the encoding records to find the corresponding format.
			for (var i:uint=0; i<this._numTables; i++) {
				var encodingRecord:CMAPEncodingRecord = CMAPEncodingRecord(this.encodingRecords[i]);
				if (encodingRecord.platformID == platformID && encodingRecord.encodingID == encodingID)
					return this.subTables[i] as CMAPFormat;
			}
			
			return null;
		}
		
		/**
		 * Table version number.
		 */
		public function get version( ):uint
		{
			return this._version;
		}
		
		
		/**
		 * Number of encoding tables.
		 */
		public function get numTables( ):uint
		{
			return this._numTables;
		}
	}
}