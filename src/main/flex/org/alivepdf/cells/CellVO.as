package org.alivepdf.cells
{
    import org.alivepdf.colors.Color;
    
	/**
	 * the Cell VO is a description of a Text Cell to be rendered to PDF
	 * 
	 */
	public class CellVO
	{
		public var x              : Number;
		public var y              : Number;
		public var width          : Number;
		public var height         : Number;
		public var fontFamily     : String;
		public var fontStyle      : String;
		public var fontSizePt     : Number;
		public var text           : String;
		public var border         : Boolean = false;
		public var fill           : Number = 0;
		public var link           : String = '';
		public var color          : Color;
		public var characterSpace : Number;
		
	}
}