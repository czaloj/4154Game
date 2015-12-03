package game;
import openfl.geom.Point;
import haxe.ds.IntMap;

/**
 * ...
 * @author Sophie Huang
 */

class Region
{
    public static inline var LEFT:Int = 1;
    public static inline var RIGHT:Int = 2;
    public static inline var JUMP_LEFT:Int = 3;
    public static inline var JUMP_RIGHT:Int = 4;

    public var id:Int;
    //center
    public var position:Point = new Point(); // center
    public var minPoint:Point = new Point();
    public var maxPoint:Point = new Point();
    public var neighbors: Array<Connection> =[];

    public function new(name:Int)
    {
        id = name;
    }

    public static function initPathTable(s:GameState) {
        for (reg in s.regionLists) {
            var pathTbl:IntMap<Int> = new IntMap<Int>();
            for (dst in s.regionLists) {
                pathTbl.set(dst.id, reg.computeDirection(dst, s));
            }
            s.pathTbl.set(reg.id, pathTbl);
        }
    }

    public function addNeighbor(reg:Region, flag:Int) {
        var neighbor:Connection = new Connection(reg.id, flag, reg.position.subtract(position).length);
        neighbors.push(neighbor);
    }


    public function getDirection(dst:Region, s:GameState) {
        if (dst != null) {
            return s.pathTbl.get(this.id).get(dst.id);
        } else {
            return 0;
        }
    }

    private function computeDirection(dst:Region, s:GameState) {
        try {
            if ((dst != null)&&(this.id != dst.id)) {
                var pathTbl:IntMap<Path> = new IntMap<Path>();
                var selfPath:Path = new Path([], 0);
                pathTbl.set(this.id, selfPath);
                findPath(this, dst, pathTbl, s);
                var nextReg = pathTbl.get(dst.id).path[0].id;
                for (neighbor in neighbors) {
                    if (neighbor.region == nextReg) {
                        return neighbor.direction;
                    }
                }
            }
        } catch(e:Dynamic) trace("Error: region contains no neighbors.");
        return 0;
    }

    private static function findPath(src:Region, dst:Region, pathTbl:IntMap<Path>,s:GameState) {
        if (src.id == dst.id) {
            return;
        }
        for (neighbor in src.neighbors) {
            var newPath:Path = new Path([], 0);
            if (pathTbl.get(src.id) !=null){
                newPath.path = pathTbl.get(src.id).path.copy();
                newPath.distance = pathTbl.get(src.id).distance;
            }
            newPath.path.push(s.regionLists.get(neighbor.region));
            newPath.distance += neighbor.distance;
            if (pathTbl.exists(neighbor.region)) {
                var curPath = pathTbl.get(neighbor.region);
                if (newPath.distance < curPath.distance) {
                    pathTbl.set(neighbor.region, newPath);
                    findPath(s.regionLists.get(neighbor.region), dst, pathTbl, s);
                }
            } else {
                pathTbl.set(neighbor.region, newPath);
                findPath(s.regionLists.get(neighbor.region), dst, pathTbl, s);
            }
        }
    }
}