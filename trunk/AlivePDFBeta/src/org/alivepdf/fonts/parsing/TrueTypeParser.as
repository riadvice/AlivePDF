package org.alivepdf.fonts.parsing
{
	import flash.utils.ByteArray;
	import org.alivepdf.fonts.parsing.tables.cmap.CMAPFormat;
	import org.alivepdf.fonts.parsing.tables.HMTXTable;
	import org.alivepdf.fonts.parsing.tables.CMAPTable;
	import org.alivepdf.fonts.parsing.tables.HEADTable;
	
	/**
	 * This class parses any .ttf or .otf font and extract all the needed informations for AlivePDF
	 * @author Thibault Imbert
	 * 
	 */	
	public final class TrueTypeParser
	{	
		private var fontStream:ByteArray;
		private var nb:Number;
		private var offset:Number;
		private var fsType:Number;
		private var restrictedLicense:Boolean;
		private var previewPrint:Boolean;
		private var editable:Boolean;
		public var ascender:Number;
		public var descender:Number;
		private var found:Boolean;
		public var italicAngle:Number;
		public var underlinePosition:Number;
		public var underlineThickness:Number;
		public var isFixedPitch:Boolean;
		public var numGlyphs:Number;
		public var fontRevision:Number;
		private var numOfLongHorMetrics:Number;
		public var header:int;
		public var designer:String;
		public var manufacturer:String;
		
		public var notice:String;
		public var flags:uint;
		public var familyName:String;
		public var fontName:String;
		public var weight:String;
		public var fullName:String;
		public var version:String;
		public var xMin:int;
		public var yMin:int;
		public var xMax:int;
		public var yMax:int;
		public var leftSideBearing:Array;
		public var charactersWidth:Object;
		public var widths:Array;
		public var averageWidth:int;
		public var fontWeight:int;
		public var fontWidth:int;
		public var unitsPerEm:Number;
		public var xHeight:int;
		public var capitalHeight:int;
		public var metricDataFormat:int;
		
		private static const TRUETYPE:int = 0x10000;
		private static const OPENTYPE:int = 0x4F54544F;
		
		private static const HHEA:String = "hhea";
		private static const CMAP:String = "cmap";
		private static const HEAD:String = "head";
		private static const POST:String = "post";
		private static const MAXP:String = "maxp";
		private static const HMTX:String = "hmtx";
		private static const NAME:String = "name";
		private static const OS2:String = "OS/2";
		
		//--------------------------------------
		//  Tables.
		//--------------------------------------
		
		private var cmapTable:CMAPTable;
		private var headTable:HEADTable;
		private var hmtxTable:HMTXTable;
		
		public function load ( bytes:ByteArray ):void
		{	
			parse ( bytes );	
		}
		
		private function parse ( bytes:ByteArray ):void	
		{	
			charactersWidth = new Object();
			fontStream = bytes;
			header = fontStream.readUnsignedInt();
			
			if ( !(header == TrueTypeParser.TRUETYPE || header == TrueTypeParser.OPENTYPE) ) throw new Error("Font not supported, make sure you passed a valid TrueType font.");
			
			parseCMAP();
			parseHEAD();
			parseOS2();
			parseNAME();
			parseHHEA();
			parsePOST();
			parseMAXP();
			parseHMTX();
		}
		
		private function parseCMAP():void
		{
			found = findTable( TrueTypeParser.CMAP );
			// Create CMAP table.
			this.cmapTable = new CMAPTable(this.fontStream);
		}
		
		private function parseHHEA():void
		{		
			found = findTable ( TrueTypeParser.HHEA );
			if ( !found ) return;
			
			fontStream.readInt();
			ascender = fontStream.readShort()/unitsPerEm;
			descender = fontStream.readShort()/unitsPerEm;
			fontStream.position += 24;
			metricDataFormat = fontStream.readShort();
			numOfLongHorMetrics = fontStream.readUnsignedShort();	
		}
		
		private function parseHEAD():void
		{			
			found = findTable ( TrueTypeParser.HEAD );
			if ( !found ) return;
			
			headTable = new HEADTable(this.fontStream);
			fontRevision = headTable.fontRevision;
			flags = headTable.flags;
			unitsPerEm = headTable.unitsPerEm/1000;

			xMin = headTable.xMin;
			yMin = headTable.yMin;
			xMax = headTable.xMax;
			yMax = headTable.yMax;
		}
		
		private function parsePOST():void
		{	
			found = findTable ( TrueTypeParser.POST );
			if ( !found ) return;
			
			fontStream.readUnsignedInt();
			italicAngle = fontStream.readShort();
			fontStream.position += 2;
			underlinePosition = fontStream.readShort()/unitsPerEm;
			underlineThickness = fontStream.readShort()/unitsPerEm;
			isFixedPitch = Boolean ( fontStream.readUnsignedInt() );
		}
		
		private function parseMAXP():void
		{	
			found = findTable ( TrueTypeParser.MAXP );
			if ( !found ) return;
			
			fontStream.readUnsignedInt();
			numGlyphs = fontStream.readUnsignedShort();
		}
		
		
		/**
		 * Parses the HMTX (Horizontal Metrics) table.
		 */
		private function parseHMTX():void
		{
			found = findTable ( TrueTypeParser.HMTX );
			if ( !found ) return;
			
			hmtxTable = new HMTXTable(fontStream, numOfLongHorMetrics);

			// Shouldn't this format be determined dynamically?
			var cmapFormat:CMAPFormat = this.cmapTable.getFormat(3, 1);
			
			widths = new Array();
			
	        for (var i:uint = 32; i < this.numOfLongHorMetrics; i++ )
	        {
	        	var glyph:uint = cmapFormat.mapCharCodeToGlyph(i);
	        	var advanceWidth:uint = Math.round(this.hmtxTable.getAdvanceWidth(glyph)/unitsPerEm);
	        	widths.push(charactersWidth[String.fromCharCode(glyph)] = advanceWidth);
	        }
		}
		
		private function parseNAME ( ):void 
		{
			found = findTable ( TrueTypeParser.NAME );
			
			fontStream.readUnsignedShort();
			nb = fontStream.readUnsignedShort();
			offset = fontStream.readUnsignedShort();
			
			var records:Array = new Array();
			var record:NameRecord;
			
			for (var i:int = 0; i < nb; i++)
			{
				record = new NameRecord(fontStream);
				
				if ( (record.platformId == 1 && record.encodingId == 0) && (record.nameId == 0 || record.nameId == 1 || 
					record.nameId == 2 || record.nameId == 4 || record.nameId == 6 || record.nameId == 5 || record.nameId == 9 ) ) 
				{
					records.push( record );
				}	
           	}
           	
			var buffer:ByteArray = new ByteArray();
			var ins:ByteArray;
			fontStream.readBytes(buffer);
			
			var lng:int = records.length;
			
			for (i = 0; i< lng; i++)
			{		
				ins = new ByteArray();
				buffer.position = 0;
				buffer.readBytes(ins);
				record = records[i];
				NameRecord(record.decode(ins));
				
				if ( record.nameId == NameID.nameCopyrightNotice ) notice = record.record;
				else if ( record.nameId == NameID.nameFontFamilyName ) familyName = record.record;
				else if ( record.nameId == NameID.namePostscriptName ) fontName = record.record;
				else if ( record.nameId == NameID.nameFontSubfamilyName ) weight = record.record;
				else if ( record.nameId == NameID.nameFullFontName ) fullName = record.record;
				else if ( record.nameId == NameID.nameVersionString ) version = record.record;
				else if ( record.nameId == NameID.nameDesigner ) designer = record.record;
				else if ( record.nameId == NameID.nameManufacturerName ) manufacturer = record.record;
			}
		}
		
		private function parseOS2 ( ):void
		{	
			found = findTable ( TrueTypeParser.OS2 );
			
			if ( !found ) return;

			fontStream.position += 2;
			averageWidth = fontStream.readShort()/unitsPerEm;
			fontWeight = fontStream.readShort();
			fontWidth = fontStream.readShort();
			fsType = fontStream.readShort();
			
			restrictedLicense = ( fsType & 0x02 ) != 0;
			previewPrint = ( fsType & 0x04 ) != 0;
			editable = ( fsType & 0x08 ) != 0;
			
			fontStream.position += 58;
			// ascender, descender, lineGap
			fontStream.readShort();
			fontStream.readShort();
			fontStream.readShort();
			fontStream.position += 4;
			
			if ( this.cmapTable.version < 2 )
			{
				xHeight = 0;
				capitalHeight = 0;
				
			} else
			{
				fontStream.position += 8;
				xHeight = fontStream.readShort();
				capitalHeight = fontStream.readShort();
			}
			
			if ( restrictedLicense && !previewPrint && !editable ) throw new Error ("Font cannot be embedded, please check font license for embedding");
		}
		
		private function findTable ( table:String):Boolean
		{
			fontStream.position = 4;
			nb = fontStream.readShort();
			fontStream.position += 6;
			
			found = false;
			var offset:int;
			
			for (var i:int = 0; i< nb; i++ )
			{	
				if ( fontStream.readUTFBytes(4) == table )
				{
					found = true;
					break;					
				}
				fontStream.position += 12;	
			}
					
			fontStream.position += 4;
			offset = fontStream.readInt();
			fontStream.position = 0;
			fontStream.position += offset;
			
			return found;
		}
	}
}