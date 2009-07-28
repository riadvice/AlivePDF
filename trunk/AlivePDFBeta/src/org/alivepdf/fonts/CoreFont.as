package org.alivepdf.fonts
{	
	import flash.utils.getTimer;
	
	/**
	 * This class represents a core font.
	 * A "Core" font is not embedded in the PDF, its usage relies on the user system fonts.
	 * @author Thibault Imbert
	 * 
	 */	
	public class CoreFont implements IFont
	{	
		protected var _type:String;
		protected var _name:String;
		protected var _underlinePosition:int = -100;
		protected var _underlineThickness:int = 50;
		protected var _charactersWidth:Object;
		protected var _numGlyphs:int;
		protected var _resourceId:int;
		protected var _id:int;

		public function CoreFont( name:String="Helvetica" )
		{
			_name = name;
			_id = getTimer();
			_type = FontType.CORE;
			var metrics:FontMetrics = new FontMetrics();
			_charactersWidth = FontMetrics.lookUp(name);	
		}
		
		/**
		 * 
		 * @return 
		 * 
		 */		
		public function get charactersWidth():Object
		{
			return _charactersWidth;
		}
		
		/**
		 * 
		 * @return 
		 * 
		 */		
		public function get name():String
		{	
			return _name;	
		}
		
		/**
		 * 
		 * @return 
		 * 
		 */		
		public function get numGlyphs():int
		{
			return _numGlyphs;	
		}
		
		/**
		 * 
		 * @return 
		 * 
		 */		
		public function get type():String
		{
			return _type;	
		}
		
		/**
		 * 
		 * @return 
		 * 
		 */		
		public function get id ():int
		{	
			return _id;	
		}
		
		/**
		 * 
		 * @param id
		 * 
		 */		
		public function set id ( id:int ):void
		{
			_id = id;	
		}
		
		/**
		 * 
		 * @return 
		 * 
		 */		
		public function get underlineThickness():int
		{
			return _underlineThickness;;	
		}
		
		/**
		 * 
		 * @return 
		 * 
		 */		
		public function get underlinePosition():int
		{
			
			return _underlinePosition;
			
		}
		
		/**
		 * 
		 * @return 
		 * 
		 */		
		public function get resourceId():int
		{
			return _resourceId;	
		}
		
		/**
		 * 
		 * @param resourceId
		 * 
		 */		
		public function set resourceId( resourceId:int ):void
		{
			_resourceId = resourceId;	
		}
		
		public function toString ():String 
		{
			return "[CoreFont name="+name+" type=Type1]";	
		}
	}
}