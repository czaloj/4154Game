package game;

/**
 * ...
 * @author Sophie Huang
 */
class Connection
{
    public var region : Int;
    public var direction : Int;
    public var distance: Float;

    public function new(reg: Int, dir: Int, d: Float)
    {
        region = reg;
        direction = dir;
        distance = d;
    }

}