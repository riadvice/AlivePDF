package org.alivepdf.fonts
{
	/**
	 * Describes a TrueType Font
	 * @author Thibault Imbert
	 * 
	 */	
	public final class FontDescription
	{
		
		private var _ascent:int;
		private var _descent:int;
		private var _capHeight:int;
		private var _flags:int;
		private var _boundingBox:Array;
		private var _italicAngle:int;
		private var _stemV:int;
		private var _missingWidth:int;
		private var _fontWeight:String;
		private var _averageWidth:int;
		
		public function FontDescription( fontWeight:String, averageWidth:int, ascent:int, descent:int, capHeight:int, flags:int, fontBoundingBox:Array, italicAngle:int, stemV:int, missingWidth:int )
		{		
			_fontWeight = fontWeight;
			_averageWidth = averageWidth;
			_ascent = ascent;
			_descent = descent;
			_capHeight = capHeight;
			_flags = flags;
			_boundingBox = fontBoundingBox;
			_italicAngle = italicAngle;
			_stemV = stemV;
			_missingWidth = missingWidth;	
		}
		
		public function get fontWeight ():String
		{	
			return _fontWeight;	
		}
		
		public function get averageWidth ():int
		{	
			return _averageWidth;	
		}
		
		public function get ascent ():int
		{
			return _ascent;	
		}
		
		public function get descent ():int
		{	
			return _descent;	
		}
		
		public function get capHeight ():int
		{
			return _capHeight;	
		}
		
		public function get flags ():int
		{
			return _flags;	
		}
		
		public function get boundingBox ():Array
		{	
			return _boundingBox;	
		}
		
		public function get italicAngle ():int
		{
			return _italicAngle;	
		}
		
		public function get stemV ():int
		{	
			return _stemV;	
		}
		
		public function get missingWidth ():int
		{	
			return _missingWidth;	
		}
	}
}