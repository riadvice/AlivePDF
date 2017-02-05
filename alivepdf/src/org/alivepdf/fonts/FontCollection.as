package org.alivepdf.fonts
{
	public final class FontCollection
	{
		private var _name:String;
		private var styles:Array;
		
		public function FontCollection(name:String)
		{
			_name = name;
			styles = new Array();
		}
		
		public function add(style:String, font:IFont):void
		{
			styles[style] = font;
		}
		
		public function getFont(style:String):IFont
		{
			return styles[style];
		}
		
		public function hasStyle(style:String):Boolean
		{
			return styles[style] != null;
		}
		
		public function contains(fontName:String):Boolean
		{
			var found:Boolean = false;
			for each(var f:IFont in styles)
			{
				if(f.name == fontName)
				{
					found = true;
					break;
				}
			}
			return found;
		}
		
		public function get name():String
		{
			return _name;
		}
	}
}