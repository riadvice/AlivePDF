package org.alivepdf.images
{	
	import flash.utils.ByteArray;
	
	public class PDFImage implements IImage
	{
		protected var _width:int;
		protected var _height:int;
		protected var _resourceId:int;
		protected var _n:int;
		protected var _colorSpace:String;
		protected var _bitsPerComponent:int = 8;
		protected var _filter:String;
		protected var _transparency:String;
		protected var _parameters:String;
		protected var _pal:String;
		protected var ct:Number;
		protected var progressive:Boolean;
		protected var stream:ByteArray;
				
		public function PDFImage ( imageStream:ByteArray, colorSpace:String, id:int )
		{	
			stream = imageStream;
			_colorSpace = colorSpace;
			resourceId = id;
			parse();
		}
		
		public function get transparency():String
		{
			return _transparency;
		}

		public function get resourceId():int
		{
			return _resourceId;
		}

		public function set resourceId(value:int):void
		{
			_resourceId = value;
		}

		public function get parameters():String
		{
			return _parameters;
		}

		public function set pal(value:String):void
		{
			_pal = value;
		}

		public function get pal():String
		{
			return _pal;
		}

		public function set n(value:int):void
		{
			_n = value;
		}

		public function get n():int
		{
			return _n;
		}

		public function get filter():String
		{
			return _filter;
		}

		public function set colorSpace(value:String):void
		{
			_colorSpace = value;
		}

		public function get colorSpace():String
		{
			return _colorSpace;
		}

		public function set bitsPerComponent(value:int):void
		{
			_bitsPerComponent = value;
		}

		public function get bitsPerComponent():int
		{
			return _bitsPerComponent;
		}

		public function get height():int
		{
			return _height;
		}

		public function get width():int
		{
			return _width;
		}

		protected function parse():void{};
		
	    public function get bytes():ByteArray
	    {
	    	return stream;	
	    }
		
		
		
	}
}