package de.fork.ui.renderers
{ 
	import de.fork.css.CSSDeclaration;
	
	import flash.display.Sprite;
	
	public interface ICSSRenderer
	{
		function setId(id:String) : void;
		function id() : String;
		
		function setWidth(width : Number) : void;
		function width() : Number;
		function setHeight(height : Number) : void;
		function height() : Number;
		function setSize(width : Number, height : Number) : void;
		
		function setStyles(styles : Object) : void;
		function styles() : Object;
		function setComplexStyles(styles : CSSDeclaration) : void;
		function complexStyles() : CSSDeclaration;
		function setDisplay(display : Sprite) : void;
		function display() : Sprite;
		
		function draw() : void;
		
		function destroy() : void;
	}
}