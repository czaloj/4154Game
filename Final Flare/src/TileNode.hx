package;

class TileNode {
    public var x:Int;
    public var y:Int;
    public var parent:Node;

    public function new(_x:Int, _y:Int, ?n:Node) {
        x = _x;
        y = _y;
        parent = n;
    }
}