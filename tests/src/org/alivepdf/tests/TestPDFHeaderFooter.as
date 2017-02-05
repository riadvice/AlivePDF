package org.alivepdf.tests
{
  import org.alivepdf.colors.RGBColor;
  import org.alivepdf.colors.RGBColorCache;
  import org.alivepdf.fonts.CoreFont;
  import org.alivepdf.fonts.CoreFontCache;
  import org.alivepdf.fonts.FontFamily;
  import org.alivepdf.layout.Align;
  import org.alivepdf.layout.Size;
  import org.alivepdf.pdf.PDF;
  
  public class TestPDFHeaderFooter extends PDF
  {
    public function TestPDFHeaderFooter(orientation:String="Portrait", unit:String="Mm", autoPageBreak:Boolean=true, pageSize:Size=null, rotation:int=0)
    {
      super(orientation, unit, autoPageBreak, pageSize, rotation);
    }
    
    public override function header(headerText:String=''):void {
      
      var oldLeftMargin:Number = leftMargin;
      var oldTopMargin:Number = topMargin;
      leftMargin = 0;
      topMargin = 0;
      
      var newFont:CoreFont = CoreFontCache.getFont ( FontFamily.HELVETICA );
      this.setFont(newFont, 12);
      this.textStyle( RGBColorCache.getColor ( "0x000000" ) );
      this.setXY(0, 10);
      this.addCell(this.currentPage.w ,10,"Super HEADERRR !!",0,0, Align.CENTER);
      
      leftMargin = oldLeftMargin;
      topMargin = oldTopMargin;
      
      this.newLine(10);
    }
    
    public override function footer(footerText:String='', showPageNumber:Boolean=false,position:String="left"):void {
      var oldLeftMargin:Number = leftMargin;
      var oldTopMargin:Number = topMargin;
      leftMargin = 0;
      topMargin = 0;
      
      var fonte:CoreFont = CoreFontCache.getFont(FontFamily.ARIAL);
      this.setFont(fonte,9);
      this.textStyle( RGBColorCache.getColor ( "0x000000" ));
      this.setXY(0,-15);
      this.addCell(this.currentPage.w,10,"Super FOOOTERRRR !!",0,0, Align.CENTER);
      
      leftMargin = oldLeftMargin;
      topMargin = oldTopMargin;
      
      this.newLine(10);
    }
  }
}