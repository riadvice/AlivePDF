package org.alivepdf.billing
{
	import org.alivepdf.colors.RGBColor;
	import org.alivepdf.fonts.CoreFont;
	import org.alivepdf.fonts.FontFamily;
	import org.alivepdf.fonts.IFont;
	import org.alivepdf.grid.Grid;
	import org.alivepdf.grid.GridColumn;
	import org.alivepdf.layout.HorizontalAlign;
	import org.alivepdf.layout.Size;
	import org.alivepdf.pdf.PDF;
	import org.alivepdf.tools.sprintf;

	public class Invoice extends PDF
	{
		public static var dataEx:Array = [
			{reference:"TEST 1",info:"Carte Mere MSI 6378 Processeur AMD 1Ghz 128Mo SDRAM, 30 Go Disque, Cdrom, Floppy, Carte video" ,quantity:1,price:60,total:60,tva:true},
			{reference:"TEST 1",info:"blablabla" ,quantity:1,price:60,total:60,tva:true},
			{reference:"TEST 1",info:"blablabla" ,quantity:1,price:60,total:60,tva:true},
			{reference:"TEST 1",info:"blablabla" ,quantity:1,price:60,total:60,tva:true},
			{reference:"TEST 1",info:"blablabla" ,quantity:1,price:60,total:60,tva:true},
			{reference:"TEST 1",info:"blablabla" ,quantity:1,price:60,total:60,tva:true}
		];
		
		
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
			addCell(maxWidth, 5, cpcity, null, 5, align);
			
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
		
		
		
		public function addCadreTVAs():void
  		{
  			var font:IFont = new CoreFont( FontFamily.HELVETICA_BOLD );
  			this.setFont( font, 8 );

			var r1:Number = 10;
			var r2:Number = r1 + 120;
			var y1:Number = maxY - 40;
			var y2:Number = y1 + 20;

	
	    	RoundedRect(r1, y1, (r2 - r1), (y2-y1), 2.5, 'D');
		    drawLine( r1, y1+4, r2, y1+4);
		    drawLine( r1+5,  y1+4, r1+5, y2); // avant BASES HT
		    drawLine( r1+27, y1, r1+27, y2);  // avant REMISE
		    drawLine( r1+43, y1, r1+43, y2);  // avant MT TVA
		    drawLine( r1+63, y1, r1+63, y2);  // avant % TVA
		    drawLine( r1+75, y1, r1+75, y2);  // avant PORT
		    drawLine( r1+91, y1, r1+91, y2);  // avant TOTAUX
		    setXY( r1+9, y1);
		    addCell(10,4, "BASES HT");
		    setX( r1+29 );
		    addCell(10,4, "REMISE");
		    setX( r1+48 );
		    addCell(10,4, "MT TVA");
		    setX( r1+63 );
		    addCell(10,4, "% TVA");
		    setX( r1+78 );
		    addCell(10,4, "PORT");
		    setX( r1+100 );
		    addCell(10,4, "TOTAUX");
		    setFont( font, 6);
		    setXY( r1+93, y2 - 3 );
		    addCell(6,0, "T.V.A.  :");
		}
		
		
		public function createGrid( data:Array ):void
		{
			this.setX( leftMargin );
			
			var refCol:GridColumn = new GridColumn("REFERENCE", "reference", 30, HorizontalAlign.CENTER);
			var infoCol:GridColumn = new GridColumn("DESIGNATION", "info", 70, HorizontalAlign.CENTER);
			var qtyCol:GridColumn = new GridColumn("QUANTITE", "quantity", 20, HorizontalAlign.CENTER, HorizontalAlign.CENTER);
			var priceCol:GridColumn = new GridColumn("P.U. HT", "price", 20, HorizontalAlign.CENTER, HorizontalAlign.RIGHT);
			var totalCol:GridColumn = new GridColumn("MONTANT H.T.", "total", 20, HorizontalAlign.CENTER, HorizontalAlign.RIGHT);
			var tvaCol:GridColumn = new GridColumn("TVA", "tva", 20, HorizontalAlign.CENTER, HorizontalAlign.CENTER);
			
			var columns:Array = [refCol, infoCol, qtyCol, priceCol, totalCol, tvaCol];
			
			var grid:Grid = new Grid(data, 180, 100, new RGBColor(0xffffff), new RGBColor(0xffffff), false, null,
										new RGBColor(0x000000), 1, 5, 5, "O j", columns);
			
			
			
			var font:IFont = new CoreFont( FontFamily.ARIAL );
			this.setFont( font, 10 );
			this.textStyle( new RGBColor(0x000000) );
			
			this.addGrid(grid);
			
			this.addMultiCell(70, 5, dataEx[0].info, 0, "L", 0);
			
		}		
		
		
	}
}