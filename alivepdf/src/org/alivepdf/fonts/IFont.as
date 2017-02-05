package org.alivepdf.fonts
{
	import flash.events.IEventDispatcher;

	public interface IFont extends IEventDispatcher
	{
		function get name():String;
		function set name(value:String):void;
		function get id():int;
		function set id(id:int):void;
		function get type():String;
		function get resourceId():int;
		function set resourceId(id:int):void;
		function get underlinePosition():int;
		function get underlineThickness():int;
		function get charactersWidth():Object;
		function get numGlyphs():int;
	}
}