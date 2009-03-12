package org.alivepdf.data
{
	public final class GridColumn
	{
		public var _headerText:String;
		public var _dataField:String;
		
		public function GridColumn( headerText:String, dataField:String )
		{
			_headerText = headerText;
			_dataField = dataField;
		}
		
		public function get headerText():String
		{
			return _headerText;
		}
		
		public function get dataField():String
		{
			return _dataField;
		}
	}
}