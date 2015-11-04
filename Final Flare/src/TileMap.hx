package;


class TileMap {
    public var tmap = new Array<Tile>();
    public var height:Int;
    public var width:Int;

    public function new(h:Int,w:Int) {
        height = h;
        width = w;
        for (i in 0...height) {
            for (j in 0...width) {
                tmap.push(new Tile(j,i));
            }
        }
        // for (j in 0...width) {
        //     tmap.push(tmap[(j+1)*(height-2)].colorFullTile(Tile.RED));
        // }
    }

    public function getTileByCoords(x:Int,y:Int) {
        return tmap[x*width + y*height];
    }

    public function getTileByIndex(index:Int) {
        return tmap[index];
    }

    public function toIDArray() {
        var idArr = new Array<Int>();
        for (t in tmap) {
            idArr.push(t.id);
        }
        return idArr;
    }

}