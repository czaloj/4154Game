package game;
import haxe.ds.ObjectMap;
import lime.utils.IDataInput;
import openfl.geom.Point;

/**
 * ...
 * @author Sophie Huang
 */
class Platform
{
    public var id:Int;
    public var position:Point = new Point(); // Starting position
    public var dimension:Point = new Point(); // length and width of platform

    public function new(type:Int = 0, sx:Int = 0, sy:Int = 0, dx:Int = 0, dy:Int = 0)
    {
        id = type;
        position.x = sx;
        position.y = sy;
        dimension.x = dx;
        dimension.y = dy;
    }

    public static function createFromTileMap(width:Int, height:Int, foreground:Array<Int>)
    {
        var tileArr:Array<Int> = [];
        for (tile in foreground) {
            tileArr.push(tile);
        }
        var platformArr:Array<Platform> = [];
        var complete = false;
        while (!complete) {
            //find starting point
            for (tile in 0...tileArr.length) {

                if (tileArr[tile] != 0) {
                    var sx = tile % width;
                    var sy = Std.int(tile / width);
                    var w = 1;
                    var h = 1;
                    var id = tileArr[tile];
                    tileArr[tile] = 0;
                    //extend horizontally
                    for (i in sx +1 ...width) {
                        if (tileArr[width * sy + i] != 0) {
                            tileArr[width * sy + i] = 0;
                            w++;
                        }else {
                            break;
                        }
                    }
                    //extend vertically
                    for (j in sy + 1... height) {
                        var passed = true;
                        for (i in sx ... sx + w) {
                            if (tileArr[width * j +i] != 0) {
                                tileArr[width * j +i] = 0;
                            }else {
                                passed = false;
                                break;
                            }
                        }
                        if (passed) {
                           h++;
                        }else {
                            break;
                        }
                    }
                    var platform = new Platform(cast(Math.abs(id), Int), sx, sy, w, h);
                    platformArr.push(platform);
                    break;
                }
            }

            //check if complete
            var allZero = true;
            for (i in 0...(width * height)) {
                if (tileArr[i] != 0) {
                    allZero = false;
                }
            }
            if (allZero) {
               complete = true;
            }
        }
        return platformArr;
    }
}