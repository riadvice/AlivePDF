package org.alivepdf.images
{	
	import flash.utils.ByteArray;
	
	public class PDFImage implements IImage
	{
		public var width:int;
		public var height:int;
		public var resourceId:int;
		public var n:int;
		public var colorSpace:String;
		public var bitsPerComponent:int = 8;
		public var filter:String;
		public var transparency:String;
		public var parameters:String;
		public var pal:String;
		public var ct:Number;
		public var progressive:Boolean;
		protected var stream:ByteArray;
				
		public function PDFImage ( imageStream:ByteArray, colorSpace:String, id:int )
		{	
			stream = imageStream;
			this.colorSpace = colorSpace;
			resourceId = id;
			parse();
		}
		
		protected function parse():void{};
		
	    public function get bytes():ByteArray
	    {
	    	return stream;	
	    }
	}
}