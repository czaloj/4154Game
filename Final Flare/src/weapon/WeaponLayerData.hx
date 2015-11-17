package weapon;

import openfl.geom.Point;

class WeaponLayerData {
    public var sx:Int;
    public var sy:Int;
    public var w:Int;
    public var h:Int;
    public var offX:Int;
    public var offY:Int;
    
    public function new(sx:Int, sy:Int, w:Int, h:Int, offX:Int, offY:Int) {
        this.sx = sx;
        this.sy = sy;
        this.w = w;
        this.h = h;
        this.offX = offX;
        this.offY = offY;
    }
}
