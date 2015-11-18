package game;
import game.neighbors;

/**
 * ...
 * @author Sophie Huang
 */

typedef Connection = { region : Region, direction : Int }
class Region
{
    public static inline var LEFT:Int = 1;
    public static inline var RIGHT:Int = 2;
    public static inline var JUMP_LEFT:Int = 3;
    public static inline var JUMP_RIGHT:Int = 4;

    public var id:Int;
    public var neighbors: Array<Connection> =[];

    public function new(name:Int)
    {
        id = name;
    }

    public function addNeighbor(reg:Region, flag:Int) {
        neighbors.push( {reg,flag} );
    }

}