package org.alivepdf.text
{
	import org.alivepdf.links.ILink;
	import org.alivepdf.pdf.PDF;
	
	public class Cell
	{
		
        public var width:Number=0;
        private var height:Number=0;
        private var text:String='';
        private var border:*=0;
        private var ln:Number=0;
        private var align:String='';
        private var fill:Number=0;
        private var link:ILink;
        
        public function Cell( pWidth:Number=0, pHeight:Number=0, pText:String='', pBorder:*=0, pLn:Number=0, pAlign:String='', pFill:Number=0, pLink:ILink=null)
        {
                width = pWidth;
                height = pHeight;
                text = pText;
                border = pBorder;
                ln = pLn;
                align = pAlign;
                fill = pFill;
                link = pLink;
        }
        
        public function addCell ( myPDF:PDF ):void
        {
        
        	myPDF.addCell(width,height,text,border,ln,align,fill,link);
               
        }
	}

}