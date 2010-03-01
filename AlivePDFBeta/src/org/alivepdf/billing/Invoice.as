package org.alivepdf.billing
{
	import org.alivepdf.colors.RGBColor;
	import org.alivepdf.fonts.CoreFont;
	import org.alivepdf.fonts.FontFamily;
	import org.alivepdf.fonts.IFont;
	import org.alivepdf.layout.HorizontalAlign;
	import org.alivepdf.layout.Size;
	import org.alivepdf.pdf.PDF;
	import org.alivepdf.tools.sprintf;

	public class Invoice extends PDF
	{
		public function Invoice(orientation:String='Portrait', unit:String='Mm', pageSize:Size=null, rotation:int=0)
		{
			super(orientation, unit, pageSize, rotation);
		}
		
		public function maxWidth():Number
  		{
    		return this.getCurrentPage().w - rightMargin - leftMargin;
  		}


		public function RoundedRect(x:Number, y:Number, w:Number, h:Number, r:Number, style:String = ''):void
  		{
  			var hp:Number = getCurrentPage().h;
  			
  			var op:String;
     		if(style=='F')
        		op='f';
     		else if(style=='FD' || style=='DF')
        		op='B';
    		else
        		op='S';
    		var MyArc:Number = 4/3 * (Math.sqrt(2) - 1);
    		write(sprintf('%.2f %.2f m',(x+r)*k,(hp-y)*k ));
    		var xc:Number = x+w-r ;
    		var yc:Number = y+r;
    		write(sprintf('%.2f %.2f l', xc*k,(hp-y)*k ));

    		_Arc(xc + r*MyArc, yc - r, xc + r, yc - r*MyArc, xc + r, yc);
    		xc = x+w-r;
    		yc = y+h-r;
		    write(sprintf('%.2f %.2f l',(x+w)*k,(hp-yc)*k));
		    _Arc(xc + r, yc + r*MyArc, xc + r*MyArc, yc + r, xc, yc + r);
		    xc = x+r ;
		    yc = y+h-r;
		    write(sprintf('%.2f %.2f l',xc*k,(hp-(y+h))*k));
		    _Arc(xc - r*MyArc, yc + r, xc - r, yc + r*MyArc, xc - r, yc);
		    xc = x+r ;
		    yc = y+r;
		    write(sprintf('%.2f %.2f l',(x)*k,(hp-yc)*k ));
		   	_Arc(xc - r, yc - r*MyArc, xc - r*MyArc, yc - r, xc, yc - r);
		    write(op);
  		}
  		  
		private function _Arc(x1:Number, y1:Number, x2:Number, y2:Number, x3:Number, y3:Number):void
	  	{
	    	write(sprintf('%.2f %.2f %.2f %.2f %.2f %.2f c ', x1*k, (currentPage.h-y1)*k,
	        			x2*k, (currentPage.h-y2)*k, x3*k, (currentPage.h-y3)*k));
	  	}
	  	
	  	/**
	  	 * 
	  	 * Returns the number of lines to display properly this text in the specific width
	  	 * 
	  	 * 
	  	 * @param texte String		The text on which the calcul is done
	  	 * @param largeur String	The specific width where the text will be displayed
	  	 * @return Number 			Number of lines
	  	 * 
	  	 */
	  	public function SizeOfText( texte:String, largeur:Number ):Number
  		{
      		var index:Number    = 0;
     		var nb_lines:Number = 0;
      		var loop:Boolean     = true;
      		var line:String;
      		while ( loop )
      		{
         		var pos:int = texte.indexOf("\n");
         		if (pos != -1)
         		{
                	loop  = false;
                	line = texte;
         		}
         		else
         		{
            		line = texte.substring(index, pos);
            		texte = texte.substring( pos+1 );
         		}
         		var length:Number = Math.floor( getStringWidth( line ) );
         		var res:Number = 1 + Math.floor( length / largeur) ;
         		nb_lines += 5 * res;
      		}

      		return nb_lines;
  		}




		public function addCompanyBox(company:Company, y:Number, align:String="L"):void
		{
			setXY(leftMargin,y);
			
			var maxWidth:Number = maxWidth();
			
			addCell(maxWidth, 5, company.name, null, 0, align);
			setXY(leftMargin,y+5);
			addCell(maxWidth, 5, company.address, null, 0, align);
			setXY(leftMargin,y+10);
			var cpcity:String = company.postalCode + " " + company.city;
			addCell(maxWidth, 5, cpcity, null, 0, align);
			
			//addCell(getStringWidth(company.name), 5, company.name);
			//addCell(getStringWidth(company.name), 5, company.name);
		}
		
		public function addCompany(company:Company):void
		{
			addCompanyBox(company, topMargin);
			
//			setXY(x1,y1);
//			var font:IFont = new CoreFont(FontFamily.ARIAL);
//			setFont( font, 12 );
//			var nameWidth:int = getStringWidth( name );
//			addCell(nameWidth, 5, name);
//			setXY(x1,y1+5);
//			
//			var addressWidth:int = getStringWidth( address );
//			
//			addMultiCell( addressWidth, 10, address);
			
			
		}
		
		public function addDate( date:Object ):void
	  	{
			
			var r1:int = maxWidth() - 61;
			var r2:int = r1 + 30;
			var y1:int  = 17;
			var y2:int  = y1 ;
			var mid:int = y1 + (y2 / 2);
			RoundedRect(r1, y1, (r2 - r1), y2, 3.5, 'D');
		 	lineStyle( new RGBColor ( 0x000000 ), 1, 0 );
		 	drawLine ( r1, mid, r2, mid );
			this.setXY( r1 + (r2-r1)/2 - 5, y1+3 );
			
			var font:IFont = new CoreFont( FontFamily.HELVETICA_BOLD );
			this.setFont( font, 10);
			this.addCell(10, 5, "DATE", 0, 0, "C");
			this.setXY( r1 + (r2-r1)/2 - 5, y1+9 );
			font.name = FontFamily.HELVETICA;
			this.setFont( font, 10);
			this.addCell(10, 5, date.toString(), 0, 0, "C");
		}

		
		public function addClientAddress( company:Company ):void
		{
			addCompanyBox(company, 40, HorizontalAlign.RIGHT);
		}
		
		
		public function addReglement( mode:String ):void
  		{
  			var r1:Number = 10;
    		var r2:Number  = r1 + 60;
    		var y1:Number  = 80;
    		var y2:Number  = y1+10;
    		var mid:Number = y1 + ((y2-y1) / 2);
    		
    		RoundedRect(r1, y1, (r2 - r1), (y2-y1), 2.5, 'D');
    		this.drawLine( r1, mid, r2, mid);
    		this.setXY( r1 + (r2-r1)/2 -5 , y1+1 );
    		var font:IFont = new CoreFont( FontFamily.HELVETICA_BOLD );
    		this.setFont( font, 10);
    		this.addCell(10, 5, "MODE DE REGLEMENT", 0, 0, "C");
    		this.setXY( r1 + (r2-r1)/2 -5 , y1 + 5 );
    		font.name = FontFamily.HELVETICA;
    		this.setFont( font, 10);
    		this.addCell(10,5,mode, 0,0, "C");
  }

		
		
		public function addRemarque( remarque:String ):void
		{
			var font:IFont = new CoreFont( getFontStyleString(false, true, FontFamily.HELVETICA) );
			setFont(font, 10);
			
			
			
			var y1:Number = this.getCurrentPage().h - 50;
			setXY(leftMargin, y1);
			addMultiCell(maxWidth(), 5, "Remarque : " + remarque, 1, "J");
		}
		
		
	}
}