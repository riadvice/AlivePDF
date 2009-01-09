package org.alivepdf.colors

{
	
	public final class RGBColor implements Color
	
	{
		
		public var r:Number;
		public var g:Number;
		public var b:Number;
		
		public function RGBColor ( color:Number )
		
		{
			
			r = (color >> 16) & 0xFF;
			g = (color >> 8) & 0xFF;
			b = color & 0xFF;
			
		}
		
	}
	
}