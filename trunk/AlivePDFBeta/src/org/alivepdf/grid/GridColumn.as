package org.alivepdf.grid
{
	public final class GridColumn
	{
		private var _headerText:String;
		private var _dataField:String;
		private var _width:Number;
		
		
		
		private var _cellAlign:String;
		private var _headerAlign:String;
		
		public function GridColumn( headerText:String, dataField:String, width:Number=30, headerAlign:String="L", cellAlign:String="L" )
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