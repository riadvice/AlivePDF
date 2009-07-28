package org.alivepdf.fonts.parsing.tables
{
	import flash.utils.ByteArray;
	
	/**
	 * 
	 * @author jarense
	 * TODO: add more getters.
	 */	
	public class HEADTable
	{
		private var _version:int;
		private var _fontRevision:int;
		private var _checksumAdjustment:uint;
		private var _magicNumber:uint;
		private var _flags:uint;
		private var _unitsPerEm:uint;
		
		private var _created:uint;
		private var _modified:uint;
		
		private var _xMin:int;
		private var _yMin:int;
		private var _xMax:int;
		private var _yMax:int;
		
		private var _macStyle:uint;
		
		private var _lowestRecPPEM:uint;
		private var _fontDirectionHint:int;
		private var _indexToLocFormat:int;
		private var _glyphDataFormat:int;
		
		public function HEADTable(data:ByteArray)
		{
			
			this._version = data.readInt();
			this._fontRevision = data.readInt();
			this._checksumAdjustment = data.readInt();
			this._magicNumber = data.readInt();
			
			this._flags = data.readUnsignedShort();
			this._unitsPerEm = data.readUnsignedShort();
			
			this._created = data.readDouble();
			this._modified = data.readDouble();
			
			this._xMin = data.readShort();
			this._yMin = data.readShort();
			this._xMax = data.readShort();
			this._yMax = data.readShort();
			
			this._macStyle = data.readUnsignedShort();
			this._fontDirectionHint = data.readShort();
			this._lowestRecPPEM = data.readUnsignedShort();
			this._indexToLocFormat = data.readShort();
			this._glyphDataFormat = data.readShort();
		}
		
		
		public function get version( ):int {
			return this._version;
		}
		
		
		public function get fontRevision( ):int {
			return this._fontRevision;
		}
		
		
		/**
		 * Bit 0:	Baseline for font at y=0;
		 * Bit 1:	Left sidebearing point at x=0;
		 * Bit 2:	Instructions may depend on point size;
		 * Bit 3:	Force ppem to integer values for all internal scaler math; may use fractional ppem sizes if this bit is clear;
		 * Bit 4:	Instructions may alter advance width (the advance widths might not scale linearly);
		 * Bits 5-10: These should be set according to Apple's specification. However, they are not set in OpenType;
		 * Bit 11:	Font data is 'lossless', as a result of having been compressed and decompressed with the Agfa MicroType Express engine;
		 * Bit 12:	Font converted (produce compatible metrics);
		 * Bit 13:	Font optimized for ClearType™. Note, fonts that rely on embedded bitmaps (EBDT) for rendering should not be considered optimized
		 * 			for ClearType, and therefore should keep this bit cleared.
		 * Bit 14:	Reserved, set to 0.
		 * Bit 15:	Reserved, set to 0.
		 * @return 
		 * 
		 */		
		public function get flags( ):uint {
			return this._flags;
		}
		
		
		/**
		 * Valid range is from 16 to 16384. This value should be a power of 2 for fonts that have TrueType outlines.
		 * @return 
		 * 
		 */		
		public function get unitsPerEm( ):uint {
			return this._unitsPerEm;
		}
		
		
		/**
		 * @return xMin for all glyph bounding boxes.
		 */		
		public function get xMin( ):int {
			return this._xMin;
		}
		
		
		/**
		 * @return yMin for all glyph bounding boxes.
		 */		
		public function get yMin( ):int {
			return this._yMin;
		}
		
		
		/**
		 * @return xMax for all glyph bounding boxes.
		 */		
		public function get xMax( ):int {
			return this._xMax;
		}
		
		
		/**
		 * @return yMax for all glyph bounding boxes.
		 */		
		public function get yMax( ):int {
			return this._yMax;
		}
		
		
		public function toString( ):String {
			var str:String = '=== HEAD Table ===\n';
			str += 'version:\t' + this._version + '\n';
			str += 'fontRevision:\t' + this._fontRevision + '\n';
			str += 'checksumAdjustment:\t' + this._checksumAdjustment + '\n';
			str += 'magicNumber:\t' + this._magicNumber + '\n';
			str += 'flags:\t' + this._flags + '\n';
			str += 'unitsPerEm:\t' + this._unitsPerEm + '\n';
			str += 'created:\t' + this._created + '\n';
			str += 'modified:\t' + this._modified + '\n';
			str += 'xMin:\t' + this._xMin + '\n';
			str += 'yMin:\t' + this._yMin + '\n';
			str += 'xMax:\t' + this._xMax + '\n';
			str += 'yMax:\t' + this._yMax + '\n';
			str += 'macStyle:\t' + this._macStyle + '\n';
			str += 'lowestRecPPEM:\t' + this._lowestRecPPEM + '\n';
			str += 'fontDirectionHint:\t' + this._fontDirectionHint + '\n';
			str += 'indexToLocFormat:\t' + this._indexToLocFormat + '\n';
			str += 'glyphDataFormat:\t' + this._glyphDataFormat + '\n';
			str += '==================\n';
			return str;
		}
	}
}