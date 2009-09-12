package org.alivepdf.fonts.parsing.tables.cmap
{
	import flash.utils.ByteArray;
	
	/**
	 * Format 4: Segment mapping to delta values.
	 */
	public class CMAPFormat4 extends CMAPFormat
	{
		/**
		 * The number of segments.
		 */
		private var _segCount:uint;
		
		/**
		 * 2 x segCount.
		 */
		private var _segCountX2:uint;
		
		
		private var _searchRange:uint;
		private var _entrySelector:uint;
		private var _rangeShift:uint;
		
		/**
		 * The last character code per segment.
		 */
		private var endCodePerSegment:Array;
		
		/**
		 * 
		 */
		private var _reservedPad:uint;
		
		/**
		 * The first character code per segment.
		 */
		private var startCodePerSegment:Array;
		
		
		private var idDeltaPerSegment:Array;
		private var idRangeOffset:Array;
		
		/**
		 * Glyph index array.
		 */		
		private var glyphIndexArray:Array;
		
		
		public function CMAPFormat4(format:uint, length:uint, language:uint, data:ByteArray)
		{
			
			super(4, length, language, data);
			
			// Parse the incoming data, in this order!
			this._segCountX2 = data.readUnsignedShort();
			this._segCount = this._segCountX2/2;
			this._searchRange = data.readUnsignedShort();
			this._entrySelector = data.readUnsignedShort();
			this._rangeShift = data.readUnsignedShort();
			
			// Create arrays..
			this.endCodePerSegment = new Array(this._segCount);
			this.startCodePerSegment = new Array(this._segCount);
			this.idDeltaPerSegment = new Array(this._segCount);
			this.idRangeOffset = new Array(this._segCount);
			
			// ..and fill them.
			var i:uint;
			for (i=0; i<this._segCount; i++)
				this.endCodePerSegment[i] = data.readUnsignedShort();
			
			// Not sure what this one is for.
			this._reservedPad = data.readUnsignedShort();
			
			for (i=0; i<this._segCount; i++)
				this.startCodePerSegment[i] = data.readUnsignedShort();
			
			for (i=0; i<this._segCount; i++)
				this.idDeltaPerSegment[i] = data.readUnsignedShort();
			
			for (i=0; i<this._segCount; i++)
				this.idRangeOffset[i] = data.readUnsignedShort();
			
			// ?
			var numGlyphs:uint = (this._length - (8*this._segCount + 16)) / 2;
			this.glyphIndexArray = new Array(numGlyphs);
			for (i=0; i<numGlyphs; i++)
				this.glyphIndexArray[i] = data.readUnsignedShort();
			
			trace(this)
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function mapCharCodeToGlyph(charCode:uint):uint {
			
			for (var i:uint=0; i<this._segCount; i++) {
				
				// Search for the first endCode >= charCode
				if (this.endCodePerSegment[i] >= charCode) {
					
					var startCode:uint = this.startCodePerSegment[i];
					// Check if the corresponding startCode <= charCode.
					if (startCode <= charCode) {
						
						var idRangeOffsetValue:uint = this.idRangeOffset[i];
						if (idRangeOffsetValue != 0) {
							
							// Mapping relies on glyphIndexArray.
							
							// Not entirely sure about this calculation. The OpenType Font File documentation could/should be much more clear about this.
							// We seem to have the correct value earlier than described. For now we're using Allesandro's calculation.
							var sum:uint = idRangeOffsetValue + (charCode - startCode);
//							if (charCode <= 400) {
//								trace('\n===CHARCODE',charCode, '===\nsegment:\t\t',i,startCode+'-'+this.endCodePerSegment[i])
//								trace('idRangeOffsetValue:\t',idRangeOffsetValue)
//								trace('c-start\t\t',(charCode - startCode))
//								trace('delta',this.idDeltaPerSegment[i])
//								trace('sum',sum, this.glyphIndexArray[charCode - startCode]);
//								trace('sja:',idRangeOffsetValue/2, (charCode - startCode), idRangeOffsetValue, (idRangeOffsetValue/2 + (charCode - startCode) + idRangeOffsetValue))
//								trace('sja2',(idRangeOffsetValue/2 + (charCode - startCode) + idRangeOffsetValue)+this.idDeltaPerSegment[i]);
//								trace('sja3',((idRangeOffsetValue/2 + (charCode - startCode) + idRangeOffsetValue)+this.idDeltaPerSegment[i])%65536);
//								trace('sdfgdf',idRangeOffsetValue/2 + (charCode - startCode) - (this._segCount - i), this.glyphIndexArray[idRangeOffsetValue/2 + (charCode - startCode) - (this._segCount - i)])
//							}
							return this.glyphIndexArray[idRangeOffsetValue/2 + (charCode - startCode) - (this._segCount - i)];
							
						}
						else {
							// The documentation says: "If the idRangeOffset is 0, the idDelta value is added to the character code offset
							// (i.e. idDelta[i] + c) to get the corresponding glyph index. Again, the arithmetic is modulo 65536."
							return (this.idDeltaPerSegment[i] + charCode) % 65536;
						}
					}
				}
			}
			
			// Return 0 (missing glyph).
			return 0;
		}
		
		
		public function toString( ):String {
			var str:String = '=== CMAPFormat4 ===\n';
			str += 'segCount:\t\t' + this._segCount + '\n';
			str += 'segCountX2:\t\t' + this._segCountX2 + '\n';
			str += 'searchRange:\t\t' + this._searchRange + '\n';
			str += 'entrySelector:\t\t' + this._entrySelector + '\n';
			str += 'rangeShift:\t\t' + this._rangeShift + '\n';
			str += 'endCodePerSegment:\t' + this.endCodePerSegment + '\n';
			str += 'startCodePerSegment:\t' + this.startCodePerSegment + '\n';
			str += 'idDeltaPerSegment:\t' + this.idDeltaPerSegment + '\n';
			str += 'idRangeOffset:\t\t' + this.idRangeOffset + '\n';
			str += 'glyphIndexArray ('+this.glyphIndexArray.length+'):\t' + this.glyphIndexArray + '\n';
			str += '===================\n';
			return str;
		}
	}
}