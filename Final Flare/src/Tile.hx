package;

import graphics.Renderer;
// import openfl.geom.Rectangle;
// import openfl.display;
import starling.display.Quad;

class Tile {
	private static inline var TWIDTH:Float = Renderer.TILE_HALF_WIDTH;
	private static inline var RED:UInt = 0xFF0000;
	private static inline var BLUE:UInt = 0x000FFF;
	private static inline var GREEN:UInt = 0x008000;

	public static var RED_TILE:Quad = new Quad(TWIDTH,TWIDTH,RED);
	public static var BLUE_TILE:Quad = new Quad(TWIDTH,TWIDTH,BLUE,true);
	public static var GREEN_TILE:Quad = new Quad(TWIDTH,TWIDTH,GREEN,true);



	//public function 
}