package org.alivepdf.grid
{
	import org.alivepdf.colors.IColor;
	import org.alivepdf.colors.RGBColor;
	
	public class GridCell
	{
		public var text:String;
		public var backgroundColor:IColor;
		
		public function GridCell( text:String, bgcolor:IColor=null )
		{
			this.text = (text == null) ? "" : text;
			this.backgroundColor = bgcolor ? bgcolor : new RGBColor(0xffffff);
		}
	}
}