package org.alivepdf.images
{
	import flash.utils.ByteArray;
	
	public final class GIFImage extends PDFImage
	{
		public static const HEADER:String = "GIF";
		
		public function GIFImage(imageStream:ByteArray, id:int)	
		{
			super ( imageStream, ColorSpace.DEVICE_RGB, id );
		}
	}
}