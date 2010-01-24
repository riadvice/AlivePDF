package org.alivepdf.events
{
	import flash.events.Event;
	
	public class CharacterEvent extends Event
	{
		protected var _missingCharacter:String;
		protected var _fontName:String;
		
		public static const CHARACTER_MISSING:String = "missingCharacter";
		
		public function CharacterEvent(type:String, fontName:String, missingCharacter:String)
		{
			super(type, false, false);
			_fontName = fontName;
			_missingCharacter = missingCharacter;
		}
		
		public function get missingCharacter():String
		{
			return _missingCharacter;
		}
		
		public function get fontName():String
		{
			return _fontName;
		}
	}
}