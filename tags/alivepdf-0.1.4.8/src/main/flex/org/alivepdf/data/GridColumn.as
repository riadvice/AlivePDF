package org.alivepdf.data
{
	public final class GridColumn
	{
		public var _headerText:String;
		public var _dataField:String;
		public var _width:int;
		public var _align:String;
		
		public function GridColumn( headerText:String, dataField:String, width:int, align:String="L" )
		{
			_headerText = headerText;
			_dataField = dataField;
			_width = width;
			_align = align;
		}
		
		public function get headerText():String
		{
			return _headerText;
		}
		
		public function get dataField():String
		{
			return _dataField;
		}
		
		public function get width():int
		{
			return _width;
		}
		
		public function get align():String
		{
			return _align;
		}
	}
}