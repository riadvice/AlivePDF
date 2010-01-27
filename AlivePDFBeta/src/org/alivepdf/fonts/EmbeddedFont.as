package org.alivepdf.fonts
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.utils.ByteArray;
	
	import org.alivepdf.events.CharacterEvent;
	import org.alivepdf.fonts.FontMetrics;
	
	/**
	 * This class represents an embedded font.
	 * An "Embedded" font is embedded in the PDF which results in a bigger PDF size.
	 * @author Thibault Imbert
	 * 
	 */	
	public class EmbeddedFont extends CoreFont implements IFont
	{	
		protected var _differences:String;
		protected var _stream:ByteArray;
		protected var _description:FontDescription;
		protected var _originalSize:int;
		protected var _version:String;
		protected var _weight:String;
		protected var _widths:Object;
		protected var _afmParser:AFMParser;
		protected var _encoding:Class;
		
		/**
		 * 
		 * @param stream The font stream - TrueType (.TTF) or OpenType (.OTF)
		 * @param afm Adobe Font Metrics file (.AFM)
		 * @param codePage The character mapping table - Default CodePage.1252
		 * 
		 */		
		public function EmbeddedFont( stream:ByteArray, afm:ByteArray, codePage:Class )
		{	
			_afmParser = new AFMParser( stream, afm, codePage );
			_afmParser.addEventListener( CharacterEvent.CHARACTER_MISSING, characterMissing );
			_widths = _afmParser.widths;
			FontMetrics.add ( _afmParser.fontName, _widths );
			super ( _afmParser.fontName );
			_type = _afmParser.type;
			_encoding = codePage;
			_description = new FontDescription ( _afmParser.weight, _afmParser.missingWidth, _afmParser.ascender, _afmParser.descender, _afmParser.capHeight, 32, _afmParser.boundingBox, 
												 _afmParser.italicAngle, _afmParser.stemV,  _afmParser.missingWidth );
			_underlinePosition = _afmParser.underlinePosition;
			_underlineThickness = _afmParser.underlineThickness;
			_weight = _afmParser.weight;
			_differences = _afmParser.differences;
			_originalSize = stream.length;
			stream.compress();
			_stream = stream;
		}
		
		private function characterMissing ( e:CharacterEvent ):void
		{
			dispatchEvent( e );
		}
		
		/**
		 * 
		 * @return 
		 * 
		 */		
		public function get encoding():Class
		{
			return _encoding;	
		}
		
		/**
		 * 
		 * @return 
		 * 
		 */		
		public function get widths():Object
		{
			return _widths;	
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
		
		/**
		 * 
		 * @return 
		 * 
		 */		
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
			return "[EmbeddedFont name="+name+" weight="+weight+" type="+type+"]";	
		}
	}
}