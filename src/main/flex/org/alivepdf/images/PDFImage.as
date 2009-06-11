package org.alivepdf.images
{
	import flash.utils.ByteArray;
	
	public class PDFImage implements IImage
	{	
		protected var stream:ByteArray;
		public var width:int;
		public var height:int;
		public var i:int;
		public var n:int;
		public var cs:String = "DeviceRGB";
		public var bpc:int = 8;
		public var f:String;
		public var trns:String;
		public var parameters:String;
		public var pal:String;
		public var ct:Number;
		public var progressive:Boolean;
				
		public function PDFImage ( imageStream:ByteArray, id:int )
		{
			stream = imageStream;
			
			i = id;
		}
			
	    public function get bytes():ByteArray
	    {
	    	return stream;	
	    }
	}
}