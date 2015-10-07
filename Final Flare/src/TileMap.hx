package;


class TileMap {
    private var tmap = new Array<Tile>();

    public function new(height:Int,width:Int) {
        for (i in 0...height) {
            for (j in 0...width) {
                tmap.push(new Tile(j,i));
            }
        }
        for (j in 0...width) {
            tmap.push(tmap[(j+1)*(height-2)].setTileTexture(Tile.GREEN));
        }
    }

    public function getTileByCoords(x:Int,y:Int) {
        return tmap[x*y];
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