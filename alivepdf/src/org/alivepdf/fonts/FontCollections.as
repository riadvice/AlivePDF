package org.alivepdf.fonts
{
	import org.alivepdf.fonts.IFont;
	import org.alivepdf.fonts.Style;
	
	public class FontCollections
	{
		private static var collections:Array = new Array();
		
		public static function add(reg:IFont, b:IFont = null, i:IFont = null, bi:IFont = null):void
		{
			var collection:FontCollection = new FontCollection(reg.name);
			collection.add(Style.NORMAL, reg);
			if(b != null) 
				collection.add(Style.BOLD, b);
			if(i != null) 
				collection.add(Style.ITALIC, i);
			if(bi != null) 
				collection.add(Style.BOLD_ITALIC, bi);
			collections.push(collection);
		}
		
		public static function lookup(name:String, style:String):IFont
		{
			var font:IFont = null;
			for each(var collection:FontCollection in collections)
			{
				if(collection.contains(name))
				{
					font = collection.getFont(style);
				}
			}
			if(font == null) 
				throw new Error("FontCollections: Font not found");
			return font;
		}
	}
}