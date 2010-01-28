package org.alivepdf.fonts
{	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
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
		protected var dispatcher:EventDispatcher;
		
		public function CoreFont( name:String="Helvetica" )
		{
			dispatcher = new EventDispatcher();
			_name = name;
			_type = FontType.TYPE1;
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
			return _underlineThickness;
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
		
		//--
		//-- IEventDispatcher
		//--
		
		public function addEventListener( type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false ):void
		{
			dispatcher.addEventListener( type, listener, useCapture, priority, useWeakReference );
		}
		
		public function dispatchEvent( event:Event ):Boolean
		{
			return dispatcher.dispatchEvent( event );
		}
		
		public function hasEventListener( type:String ):Boolean
		{
			return dispatcher.hasEventListener( type );
		}
		
		public function removeEventListener( type:String, listener:Function, useCapture:Boolean = false ):void
		{
			dispatcher.removeEventListener( type, listener, useCapture );
		}
		
		public function willTrigger( type:String ):Boolean
		{
			return dispatcher.willTrigger( type );
		}
	}
}