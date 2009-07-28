package org.alivepdf.images
{
	import flash.display.BitmapData;
	import flash.utils.ByteArray;

	public final class DoPNGImage extends PNGImage
	{
		private var bitmap:BitmapData;
		
		public function DoPNGImage( buffer:BitmapData, imageStream:ByteArray, id:int)
		{
			bitmap = buffer;
			idataBytes = imageStream;
			super(imageStream, ColorSpace.DEVICE_RGB, id);
		}
		
		protected override function parse():void
		{
			width = bitmap.width;
			height = bitmap.height;
			parameters = '/DecodeParms <</Predictor 15 /Colors 3 /BitsPerComponent '+bitsPerComponent+' /Columns '+width+'>>';
		}	
	}
}