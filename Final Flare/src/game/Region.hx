package game;
import game.Region.Path;
import openfl.geom.Point;
import haxe.ds.ObjectMap;

/**
 * ...
 * @author Sophie Huang
 */

typedef Connection = { region : Region, direction : Int, distance: Float }
typedef Path = { path: Array<Region>, distance: Float }

class Region
{
    public static inline var LEFT:Int = 1;
    public static inline var RIGHT:Int = 2;
    public static inline var JUMP_LEFT:Int = 3;
    public static inline var JUMP_RIGHT:Int = 4;

    public var id:Int;
    //center
    public var position:Point = new Point(); //center?
    public var neighbors: Array<Connection> =[];

    public function new(name:Int)
    {
        id = name;
    }

    public function addNeighbor(reg:Region, flag:Int) {
        var neighbor:Connection = { region: reg, direction: flag, distance: reg.position.subtract(position).length};
        neighbors.push(neighbor);
    }

    public function getDirection(dst:Region) {
        var pathTbl:ObjectMap<Region, Path> = new ObjectMap<Region, Path>();
        findPath(this, dst, pathTbl);
        var nextReg = pathTbl.get(dst).path[0].id;
        for (neighbor in neighbors) {
            if (neighbor.region.id == nextReg) {
                return neighbor.direction;
            }
        }
        return 0;
    }

    private static function findPath(src:Region, dst:Region, pathTbl:ObjectMap<Region, Path>) {
        if (src.id == dst.id) {
            return;
        }
        for (neighbor in src.neighbors) {
            var newPath:Path = { path: [], distance:0 };
            if (pathTbl.get(src) !=null){
                newPath.path = pathTbl.get(src).path.copy();
                newPath.distance = pathTbl.get(src).distance + neighbor.distance;
            }
            newPath.path.push(neighbor.region);
            if (pathTbl.exists(neighbor.region)) {
                var curPath = pathTbl.get(neighbor.region);
                if (newPath.distance < curPath.distance) {
                    pathTbl.set(neighbor.region, newPath);
                }
            } else {
                pathTbl.set(neighbor.region, newPath);
                findPath(neighbor.region, dst, pathTbl);
            }
        }
    }
}