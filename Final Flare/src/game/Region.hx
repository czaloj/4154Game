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
    public var position:Point;
    public var dimension:Point;
    public var neighbors: Array<Connection> =[];

    public function new(name:Int)
    {
        id = name;
    }

    public function addNeighbor(reg:Region, flag:Int) {
        neighbors.push( {reg,flag,(reg.position - position).lengths} );
    }

    public function getDirection(dst:Region) {
        var pathTbl:ObjectMap<Region, Path> = new ObjectMap<Region, Path>();
        findPath(this, dst, pathTbl);
        var nextReg = pathTbl.get(dst).path[0].id;
        for (neighbor in neighbors) {
            if (neighbor.id == nextReg) {
                return neighbor.direction;
            }
        }
    }

    private static function findPath(src:Region, dst:Region, pathTbl:ObjectMap<Region, Path>) {
        if (src.id == dst.id) {
            return;
        }
        for (neighbor in src.neighbors) {
            Path newPath = new Path().path.copy(pathTbl.get(src.region));
            newPath.path.add(neighbor.region);
            newPath.distance = pathTbl.get(src.region).distance + neighbor.distance;
            if (pathTbl.exists(neighbor.region) {
                Path curPath = pathTbl.get(neighbor.region);
                if (newPath.distance < curPath.distance) {
                    pathTbl.set(neighbor.region, newPath);
                }
            } else {
                pathTbl.set(neighbor.region, newPath);
                findPath(neighbor, dst, pathTbl);
            }
        }
    }
}