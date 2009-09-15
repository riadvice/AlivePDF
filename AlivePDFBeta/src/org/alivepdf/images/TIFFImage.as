package org.alivepdf.images
{
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	import org.alivepdf.decoding.Filter;
	
	public class TIFFImage extends PDFImage
	{
		public function TIFFImage(imageStream:ByteArray, colorSpace:String, id:int)
		{
			super(imageStream, colorSpace, id);
			//filter = Filter.DCT_DECODE;
		}
		
		protected override function parse ():void
		{
		}
	}
}