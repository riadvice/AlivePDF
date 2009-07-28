package org.alivepdf.fonts
{
	import flash.utils.ByteArray;
	import org.alivepdf.fonts.parsing.TrueTypeParser;
	
	/**
	 * This class represents an embedded font.
	 * An "Embedded" font is embedded in the PDF which results in a bigger PDF size.
	 * @author Thibault Imbert
	 * 
	 */	
	public class EmbeddedFont extends CoreFont implements IFont
	{	
		protected var _encoding:Class;
		protected var _differences:String;
		protected var _stream:ByteArray;
		protected var _description:FontDescription;
		protected var _originalSize:int;
		protected var _version:String;
		protected var _weight:String;
		protected var ttParser:TrueTypeParser;
		protected var _designer:String;
		protected var _widths:Array;
		
		public function EmbeddedFont( stream:ByteArray, codePage:Class )
		{	
			stream.position = 0;
			ttParser = new TrueTypeParser();
			ttParser.load(stream);
			var fontName:String = ttParser.fontName != null ? ttParser.fontName : "DefaultFontName";
			FontMetrics.add ( fontName, ttParser.charactersWidth );
			_widths = ttParser.widths;
			_charactersWidth = ttParser.charactersWidth;
			super ( fontName );
			_type = FontType.TRUETYPE;
			_description = new FontDescription ( ttParser.fontWeight, ttParser.averageWidth, ttParser.ascender, ttParser.descender, ttParser.capitalHeight, 32, new Array (ttParser.xMin, ttParser.yMin, ttParser.xMax, ttParser.yMax), ttParser.italicAngle, 70,  800 );
			_underlinePosition = ttParser.underlinePosition;
			_underlineThickness = ttParser.underlineThickness;
			_designer = ttParser.designer;
			_version = ttParser.version;
			_numGlyphs = ttParser.numGlyphs;
			_weight = ttParser.weight;
			_encoding = codePage;
			_differences = parse ( codePage );
			_originalSize = stream.length;
			stream.compress();
			_stream = stream;
		}
		
		private function parse ( codePage:Class ):String
		{	
			var codes:ByteArray = new codePage() as ByteArray;
			var content:String = codes.readUTFBytes( codes.length );
			var differences:String = '127 /space ';
			var sourceCodes:Array = content.split('\n');
			
			for (var i:int = 128; i< sourceCodes.length; i++)
				differences += '/'+sourceCodes[i].split(' ')[2]+' ';
		
			return differences;
		}
		
		/**
		 * 
		 * @return 
		 * 
		 */		
		public function get widths():Array
		{
			return _widths;	
		}
		
		/**
		 * 
		 * @return 
		 * 
		 */		
		public function get designer():String
		{
			return _designer;	
		}
		
		/**
		 * 
		 * @return 
		 * 
		 */		
		public function get version():String
		{
			return _version;	
		}
		
		/**
		 * 
		 * @return 
		 * 
		 */		
		public function get weight():String
		{
			return _weight;	
		}
		
		/**
		 * 
		 * @return 
		 * 
		 */		
		public function get originalSize():int
		{	
			return _originalSize;	
		}
		
		/**
		 * 
		 * @return 
		 * 
		 */		
		public function get encoding ():Class
		{	
			return _encoding;	
		}
		
		/**
		 * 
		 * @return 
		 * 
		 */		
		public function get description ():FontDescription
		{	
			return _description;	
		}
		
		/**
		 * 
		 * @return 
		 * 
		 */		
		public function get differences():String
		{
			return _differences;	
		}
			
		public function set differences( differences:String ):void
		{	
			_differences = differences;	
		}
		
		/**
		 * 
		 * @return 
		 * 
		 */		
		public function get stream():ByteArray
		{
			return _stream;	
		}
		
		public override function toString ():String 
		{	
			return "[EmbeddedFont name="+name+" numGlyphs="+numGlyphs+" type="+type+" version="+version+"]";	
		}
	}
}