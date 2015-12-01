package game;

/**
 * ...
 * @author Sophie Huang
 */
class Path
{
    public var path: Array<Region>;
    public var distance: Float;

    public function new(p: Array<Region>, d:Float)
    {
        path = p;
        distance = d;
    }

}