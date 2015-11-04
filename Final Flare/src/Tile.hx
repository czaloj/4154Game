package;

import game.World;
import graphics.Renderer;
// import openfl.geom.Rectangle;
// import openfl.display;
import starling.display.Quad;
import starling.utils.Color;

class Tile {
    private static inline var TWIDTH:Float = World.TILE_HALF_WIDTH;

    // private static inline var RED:UInt = 0xFF0000;
    // private static inline var BLUE:UInt = 0x000FFF;
    // private static inline var GREEN:UInt = 0x008000;
    // private static var RED_TILE:Quad = new Quad(TWIDTH,TWIDTH,RED);
    // private static var BLUE_TILE:Quad = new Quad(TWIDTH,TWIDTH,BLUE,true);
    // private static var GREEN_TILE:Quad = new Quad(TWIDTH,TWIDTH,GREEN,true);

    public static inline var NUM_TILES:Int = 27;
    
    public static inline var WHITE:Int = 0;
    public static inline var RED:Int = 1;
    public static inline var BLUE:Int = 2;
    public static inline var GREEN:Int = 3;
    public static inline var YELLOW:Int = 4;
    public static inline var PURPLE:Int = 5;
    public static inline var GRAY:Int = 6;
    public static inline var AQUA:Int = 7;
    public static inline var FUCHSIA:Int = 8;
    public static inline var LIME:Int = 9;
    public static inline var MAROON:Int = 10;
    public static inline var NAVY:Int = 11;
    public static inline var OLIVE:Int = 12;
    public static inline var SILVER:Int = 13;
    public static inline var TEAL:Int = 14;
    public static inline var BLACK:Int = 15;
    public static inline var PERRIWINKLE:Int = 16;
    public static inline var SKY:Int = 17;
    public static inline var PINK:Int = 18;
    public static inline var LAVENDER:Int = 19;
    public static inline var MINT:Int = 20;
    public static inline var CREAM:Int = 21;
    public static inline var BEIGE:Int = 22;
    public static inline var ORANGE:Int = 23;
    public static inline var TAN:Int = 24;
    public static inline var MAUVE:Int = 25;
    public static inline var BERRY:Int = 26;
    public static inline var BROWN:Int = 27;

    public static var tiles = [
        Color.WHITE,
        Color.RED,
        Color.BLUE,
        Color.GREEN,
        Color.YELLOW,
        Color.PURPLE,
        Color.GRAY,
        Color.AQUA,
        Color.FUCHSIA,
        Color.LIME,
        Color.MAROON,
        Color.NAVY,
        Color.OLIVE,
        Color.SILVER,
        Color.TEAL,
        Color.BLACK,
        0x9e9bcc,
        0xc5f5fa,
        0xf788bd,
        0xf2b3ef,
        0xd2fad6,
        0xf9fcc7,
        0x75505f,
        0xfa508c,
        0x6b4801
    ];

    public var tile:Quad;
    public var id:Int;
    
    public function new(tx,ty) {
        tile = new Quad(TWIDTH,TWIDTH,tiles[WHITE]);
        id = WHITE;
        tile.x = Std.int(tx*TWIDTH);
        tile.y = Std.int(ty*TWIDTH);
        tile.visible = false;
    }

    public function IDTile(tileID:Int) {
        id = tileID;
    }

    public function colorQuarterTile(tileID:Int) {
        tile.color = tiles[tileID];
        id = tileID;
        tile.visible = true;
        return this;
    }

    public function colorFullTile(tileID:Int) {
        return this;
    }

    public function clearQuarterTile() {
        tile.visible = false;
        id = WHITE;
    }

    public function clearFullTile() {
        
    }
}