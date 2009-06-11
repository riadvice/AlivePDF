package org.alivepdf.data
{
	public final class GridColumn
	{
		public var _headerText:String;
		public var _dataField:String;
		public var _width:Number;
		public var _cellAlign:String;
		public var _headerAlign:String;
		
		public function GridColumn( headerText:String, dataField:String, width:Number, headerAlign:String="L", cellAlign:String="L" )
		{
			_headerText = headerText;
			_dataField = dataField;
			_width = width;
			_headerAlign = headerAlign;
			_cellAlign = cellAlign;
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
		
		public function get cellAlign():String
		{
			return _cellAlign;
		}
		
		public function get headerAlign():String
		{
			return _headerAlign;
		}
	}
}