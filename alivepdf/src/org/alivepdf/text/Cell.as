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
        
        public function Cell( width:Number=0, height:Number=0, text:String='', border:*=0, ln:Number=0, align:String='', fill:Number=0, link:ILink=null )
        {
			this.width = width;
            this.height = height;
            this.text = text;
            this.border = border;
            this.ln = ln;
            this.align = align;
            this.fill = fill;
			this.link = link;
        }
        
        public function addCell ( pdf:PDF ):void
        {  
        	pdf.addCell(width,height,text,border,ln,align,fill,link);       
        }
	}
}