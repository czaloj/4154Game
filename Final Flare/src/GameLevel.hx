package;

import graphics.SpriteSheet;
import openfl.geom.Point;
import openfl.Lib;
import openfl.Assets;

class GameLevel {
    public var width:Int; // Width of level
    public var height:Int; // Height of level

    // 2D array starting from upper left, coordinate (x,y) translate to index x + y * width in the array
    public var foreground:Array<Int>; // Array of identifiers for foreground tiles
    public var background:Array<Int>; // Array of identifiers for background tiles

    public var spawners:Array<Spawner>; // List of spawn points for enemies
    public var playerPt:Point; // Initial spawn point for the player

    public var parallax:Array<String>; // List of parallax image files
    public var environmentSprites:String; // Sprite sheet file for the environment
    public var environmentType:String; // Sprite sheet identifier for the environment

    public function new() {
        foreground = [];
        background = [];
        parallax = [];
        spawners = [];
        playerPt = new Point();
    }
}
