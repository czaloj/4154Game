package;


class TileMap {
    public var tmap:Array<Tile>;
    public var height:Int;
    public var width:Int;

    public function new(h:Int,w:Int) {
        height = h;
        width = w;
        tmap = [];
        for (i in 0...height) {
            for (j in 0...width) {
                tmap.push(new Tile(j,i));
            }
        }
        // for (j in 0...width) {
        //     tmap.push(tmap[(j+1)*(height-2)].colorFullTile(Tile.RED));
        // }
    }

    public function getTileByCoords(x:Int,y:Int):Tile {
        return tmap[x*width + y*height];
    }

    public function getTileByIndex(index:Int):Tile {
        return tmap[index];
    }

    public function setTileByCoords(x:Int,y:Int,t:Tile):Void {
        tmap[x*width + y*height] = t;
    }

    public function setTileByIndex(index:Int,t:Tile):Void {
        tmap[index] = t;
    }

    public function toIDArray() {
        var idArr = new Array<Int>();
        for (t in tmap) {
            idArr.push(t.id);
        }
        return idArr;
    }

}