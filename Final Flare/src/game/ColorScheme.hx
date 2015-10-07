package game;

import openfl.geom.Rectangle;

class ColorScheme{
    public var primary:UInt;
    public var secondary:UInt;
    public var tertiary:UInt;
    public var texture:Rectangle;
    
    public function new(p:UInt, s:UInt, t:UInt, tx:Int, ty:Int, tw:Int, th:Int) {
        primary = p;
        secondary = s;
        tertiary = t;
        texture = new Rectangle(tx, ty, tw, th);
    }
}
