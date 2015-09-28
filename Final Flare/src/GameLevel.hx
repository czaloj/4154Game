package;

import openfl.Lib;
import openfl.Assets;
import haxe.Serializer;
import haxe.Unserializer;

class GameLevel {
    public var width:Int; //Width of level
    public var height:Int; //Height of level

    //2D array starting from upper left, coordinate (x,y) translate to index x + y * x in the array
    public var foreground: Array<Int>; //Array of identifiers for foreground tiles
    public var background: Array<Int>; //Array of identifiers for background tiles

    public var parallax: Array<String>;//List of parallax image files, in the order of drawing

    public var entities:Array<Spawner>; //List of spawn points

    public function new() {
        foreground = [];
        background = [];
        parallax = [];
        entities = [];
    }

    public static function createFromFile(file:String):GameLevel {
        var value = Assets.getText(file);
        var unserializer = new Unserializer(value);
        return unserializer.unserialize();
    }
}
