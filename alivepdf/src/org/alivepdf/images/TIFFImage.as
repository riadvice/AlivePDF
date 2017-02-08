package org.alivepdf.images
{
    import flash.utils.ByteArray;

    public class TIFFImage extends PDFImage
    {
        public function TIFFImage( imageStream:ByteArray, colorSpace:String, id:int )
        {
            super(imageStream, colorSpace, id);
        }

        protected override function parse() : void
        {
        }
        ;
    }
}
