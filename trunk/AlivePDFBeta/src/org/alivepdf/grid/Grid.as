package org.alivepdf.grid
{
	import flash.utils.ByteArray;
	
	import org.alivepdf.colors.IColor;
	import org.alivepdf.colors.RGBColor;
	import org.alivepdf.export.CSVExport;
	import org.alivepdf.export.Export;
	import org.alivepdf.serializer.ISerializer;
	
	public class Grid
	{
		private var _data:Array;
		private var _width:Number;
		private var _height:Number;
		private var _headerHeight:int;
		private var _rowHeight:int;
		private var _x:int;
		private var _y:int;
		private var _columns:Array;
		private var _cells:Array; // array of array of GridCell
		private var _borderColor:IColor;
		private var _borderAlpha:Number;
		private var _joints:String;
		private var _backgroundColor:IColor;
		private var _headerColor:IColor;
		private var _cellColor:IColor;
		private var _alternativeCellColor:IColor;
		private var _useAlternativeRowColor:Boolean;
		private var _serializer:ISerializer;
		
		public function Grid( data:Array, width:Number, height:Number, headerColor:IColor, cellColor:IColor=null, 
								useAlternativeRowColor:Boolean=false, alternativeCellColor:IColor=null,
								borderColor:IColor=null, borderAlpha:Number=1, 
								headerHeight:int=5, rowHeight:int=5,
								joints:String="0 j", columns:Array=null)
		{
			_data = data;
			_width = width;
			_height = height;
			_borderColor = (borderColor == null) ? new RGBColor(0x000000) : borderColor; // black by default
			_borderAlpha = borderAlpha;
			_rowHeight = rowHeight;
			_headerHeight = headerHeight;
			_joints = joints;
			_headerColor = headerColor;
			_cellColor = cellColor = (cellColor == null) ? new RGBColor(0xffffff) : cellColor;
			_alternativeCellColor = (alternativeCellColor == null) ? new RGBColor(0xd3d3d3) : alternativeCellColor;
			_useAlternativeRowColor = useAlternativeRowColor;	
			if ( columns != null )
				this.columns = columns; 
		}
		
		public function export ( type:String="csv" ):ByteArray
		{
			if ( type == Export.CSV ) 
				_serializer = new CSVExport(_data, _columns);
			return _serializer.serialize();
		}
		
		
		public function generateColumns(force:Boolean=false, headerAlign:String="L", cellAlign:String="L"):void
		{
			var buffer:Array = dataProvider;
			if ( (columns != null && force ) || columns == null)
			{
				var firstItem:* = buffer[0];
				var fields:Array = new Array();
				var column:GridColumn;
				for ( var p:String in firstItem )
					fields.push ( p );
				fields.sort();
				columns = new Array();
				var fieldsLng:int = fields.length;
				for (var i:int = 0; i< fieldsLng; i++)
					columns.push ( new GridColumn ( fields[i], fields[i], this.width / fieldsLng, headerAlign, cellAlign) );
			}

		}
		
		public function generateCells():void
		{
			var buffer:Array = dataProvider;
			var lng:int = buffer.length;
			var lngColumns:int = columns.length;
			var row:Array;
			var item:Object;
			var isEven:int;
			var result:Array = new Array();
			
			for (var i:int = 0; i< lng; i++)
			{
				item = buffer[i];
				row = new Array();
				for (var j:int = 0; j< lngColumns; j++)
				{
					var cell:GridCell = new GridCell(item[columns[j].dataField]);
					cell.backgroundColor = (useAlternativeRowColor && Boolean(isEven = i&1)) 
												? alternativeCellColor : cellColor;
					row.push ( cell );
				}
				result.push( row );
			}
			
			_cells = result;
		}
		
		
		public function get columns ():Array
		{
			return _columns;
		}
		
		public function set columns ( columns:Array ):void
		{
			_columns = columns;
		}
		
		public function get cells():Array
		{
			return _cells;
		}
		
		public function get width ():Number
		{
			return _width;	
		}
		
		public function get height ():Number
		{
			return _height;	
		}
		
		public function get rowHeight():int
		{
			return _rowHeight;
		}
		
		public function get headerHeight():int
		{
			return _headerHeight;
		}
		
		public function get x ():int
		{
			return _x;	
		}
		
		public function get y ():int
		{
			return _y;	
		}
		
		public function set x ( x:int ):void
		{
			_x = x;	
		}
		
		public function set y ( y:int ):void
		{
			_y = y;
		}
		
		public function get borderColor ():IColor
		{
			return _borderColor;	
		}
		
		public function get borderAlpha ():Number
		{
			return _borderAlpha;	
		}
		
		public function get joints ():String
		{
			return _joints;	
		}
		
		public function get headerColor ():IColor
		{
			return _headerColor;	
		}
		
		public function get cellColor ():IColor
		{
			return _cellColor;	
		}
		
		public function get useAlternativeRowColor ():Boolean
		{	
			return _useAlternativeRowColor;	
		}
		
		public function get alternativeCellColor ():IColor
		{	
			return _alternativeCellColor;	
		}

		public function get dataProvider ():Array
		{
			return _data;	
		}
		
		public function toString ():String 
        {
            return "[Grid cells="+_data.length+" alternateRowColor="+_useAlternativeRowColor+" x="+x+" y="+y+"]";    
        } 
	}
}