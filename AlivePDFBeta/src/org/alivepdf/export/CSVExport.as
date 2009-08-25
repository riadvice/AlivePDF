package org.alivepdf.export
{
	import flash.utils.ByteArray;
	
	import org.alivepdf.data.GridColumn;
	import org.alivepdf.serializer.ISerializer;

	public final class CSVExport implements ISerializer
	{
		private var _data:Array;
		private var _columns:Array;
		private var _delimiter:String;
		private var buffer:String = new String();
		private var output:ByteArray = new ByteArray();
		
		public function CSVExport( data:Array, columns:Array )
		{
			_data = data;
			_columns = columns;
		}
		
		public function serialize():ByteArray
		{	
			if ( _columns == null ) throw new Error("Set the Grid.columns property to use the export feature.");
		
			var line:String;
			var lng:int = _columns.length;
			var column:GridColumn;
			var field:String;
			var delimiter:String = ";";
			
			for each ( var item:Object in _data )
			{
				line = new String();
				for ( var i:int = 0; i< lng; i++ )
				{
					column = _columns[i];
					field = item[column.dataField] != null ? item[column.dataField] : "";
					line += line.length > 0 ? delimiter+field : field;
				}
				line += "\n";
				buffer += line;
			}
			output.writeUTFBytes(buffer);
			return output;
		}
	}
}