package;
import starling.display.Quad;

class TileMap {
    private static inline var TILE_HALF_WIDTH = 16;

    public var tmap:Array<Int>;
    public var height:Int;
    public var width:Int;

    public function new(h:Int,w:Int) {
        height = h;
        width = w;
        tmap = [];
        for (i in 0...height) {
            for (j in 0...width) {
                tmap.push(Tile.WHITE);
            }
        }
    }

    public function getIDByIndex(index:Int):Int {
        return tmap[index];
    }

    public function getID(x:Int,y:Int):Int {
        return getIDByIndex(x + y*width);
    }

    public function drawTileByIndex(i:Int,tileID:Int):Quad {
        var x = i % width;
        var y = Std.int((i - x) / width);
        return drawTile(x,y,tileID);
    }

    public function drawTile(x:Int,y:Int,tileID:Int):Quad {
        var t = new Quad(TILE_HALF_WIDTH,TILE_HALF_WIDTH,Tile.tiles[tileID]);
        t.visible = true;
        t.x = Std.int(x);
        t.y = Std.int(y);
        return t;
    }

    public function setIDByIndex(index:Int,t:Int):Void {
        tmap[index] = t;
    }

    public function setID(x:Int,y:Int,t:Int):Void {
        setIDByIndex(x + y*width, t);
    }

    public function setFullTile(x:Int,y:Int,tileID:Int):Void {
        setID(x,y,tileID);
        setID(x+1,y,-tileID);
        setID(x,y+1,-tileID);
        setID(x+1,y+1,-tileID);
    }

    public function setFullTileByIndex(i:Int,tileID:Int):Void {
        var x = i % width;
        var y = Std.int((i - x) / width);
        setFullTile(x,y,tileID);
    }

    public function clearQuarterTile(x:Int,y:Int):Void {
        setID(x,y,Tile.WHITE);
    }

    public function clearQuarterTileByIndex(i:Int):Void {
        setIDByIndex(i,Tile.WHITE);
    }

    public function clearFullTile(x:Int,y:Int):Void {
        setFullTile(x,y,Tile.WHITE);
    }

    public function clearFullTileByIndex(i:Int):Void {
        setFullTileByIndex(i,Tile.WHITE);
    }
}