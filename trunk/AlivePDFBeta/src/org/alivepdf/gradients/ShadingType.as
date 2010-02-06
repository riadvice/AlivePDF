package org.alivepdf.gradients
{
	import flash.utils.ByteArray;

	public class ShadingType
	{
		public static const TYPE1:int = 1;
		public static const TYPE2:int = 2;
		public static const TYPE3:int = 3;
		public static const TYPE6:int = 6;
		
		protected var _id:int; 
		protected var _type:int; 
		protected var _coords:Array; 
		protected var _stream:ByteArray; 
		protected var _col1:String; 
		protected var _col2:String; 
		
		public function ShadingType(type:int, coords:Array, col1:String, col2:String)
		{
			_type = type;
			_coords = coords;
			_col1 = col1;
			_col2 = col2;
		}
		
		public function get stream():ByteArray
		{
			return _stream;
		}

		public function set stream(value:ByteArray):void
		{
			_stream = value;
		}

		public function get id():int
		{
			return _id;
		}

		public function set id(value:int):void
		{
			_id = value;
		}

		public function get col2():String
		{
			return _col2;
		}

		public function get col1():String
		{
			return _col1;
		}

		public function get coords():Array
		{
			return _coords;
		}

		public function get type():int
		{
			return _type;
		}
	}
}