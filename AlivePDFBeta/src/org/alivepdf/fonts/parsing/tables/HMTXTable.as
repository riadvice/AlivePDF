package org.alivepdf.fonts.parsing.tables
{
	import flash.utils.ByteArray;
	
	public class HMTXTable
	{
		private var advanceWidths:Array;
		private var leftSideBearings:Array;
		
		private var maxAdvance:int;
		private var maxAdvanceCalculated:Boolean;
		
		public function HMTXTable(data:ByteArray, numOfHMetrics:uint)
		{
			
			// Read the data.
			var i:uint;
            this.advanceWidths = new Array(numOfHMetrics);
            this.leftSideBearings = new Array(numOfHMetrics);
            
			for (i=0; i<numOfHMetrics; i++) {
 				this.advanceWidths[i] = data.readUnsignedShort();
				this.leftSideBearings[i] = data.readShort();
			}
		}
		
		/**
		 * Returns the advance width for the given glyph. If the advance width for the given glyph is
		 * not available, the advance width of the last available glyph is returned.
		 * 
		 * @param charCode
		 * @return 
		 */
		public function getAdvanceWidth(glyph:uint):int {
			
			if (glyph > this.advanceWidths.length-1) {
				return this.advanceWidths[this.advanceWidths.length-1];
			}
			else {
				return this.advanceWidths[glyph];
			}
		}
		
		
		public function getLeftSideBearing(glyph:uint):int {
			if (glyph > this.leftSideBearings.length-1) {
				return this.leftSideBearings[this.advanceWidths.length-1];
			}
			else {
				return this.leftSideBearings[glyph];
			}
		}
		
		
		/**
		 * @return The advance pixel width of the widest character in the font.
		 */		
		public function getMaxAdvance( ):int {
			
			if (! this.maxAdvanceCalculated) {
			
				this.maxAdvance = int.MIN_VALUE;
				var n:uint = this.advanceWidths.length;
				for (var i:uint=0; i<n; i++) {
					this.maxAdvance = Math.max(this.maxAdvance, this.advanceWidths[i]);
				}
				this.maxAdvanceCalculated = true;
			}
			
			return this.maxAdvance;
		}
		
		
		public function toString( ):String {
			var str:String = '=== hmtx table ===\n';
			
			var n:uint = this.advanceWidths.length;
			for (var i:uint=230; i<240; i++) {
				str += '  ' + i + '\taW ' + this.getAdvanceWidth(i) + '\tlsb ' + this.getLeftSideBearing(i) + '\n';
			}
			str += '==================\n';
			
			return str;
		}
	}
}