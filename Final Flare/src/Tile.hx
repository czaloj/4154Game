package;

import game.World;
import graphics.Renderer;
// import openfl.geom.Rectangle;
// import openfl.display;
import starling.display.Quad;

class Tile {
    private static inline var TWIDTH:Float = World.TILE_HALF_WIDTH;

    // private static inline var RED:UInt = 0xFF0000;
    // private static inline var BLUE:UInt = 0x000FFF;
    // private static inline var GREEN:UInt = 0x008000;
    // private static var RED_TILE:Quad = new Quad(TWIDTH,TWIDTH,RED);
    // private static var BLUE_TILE:Quad = new Quad(TWIDTH,TWIDTH,BLUE,true);
    // private static var GREEN_TILE:Quad = new Quad(TWIDTH,TWIDTH,GREEN,true);

    public static var WHITE:Int = 0;
    public static var RED:Int = 1;
    public static var BLUE:Int = 2;
    public static var GREEN:Int = 3;
    public static var tiles = [0xFFFFFF,0xFF0000,0x000FFF,0x008000];

    public var tile:Quad;
    public var id:Int;
    
    public function new(tx,ty) {
        tile = new Quad(TWIDTH,TWIDTH,tiles[WHITE]);
        id = WHITE;
        tile.x = Std.int(tx*TWIDTH);
        tile.y = Std.int(ty*TWIDTH);
        tile.visible = false;
    }

    public function setTileTexture(tileID:Int) {
        tile.color = tiles[tileID];
        id = tileID;
        tile.visible = true;
        return this;
    }
}