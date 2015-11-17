package weapon;
import haxe.ds.StringMap;
import openfl.geom.Point;

class WeaponLayer {
    // The sprite used for this part
    public var spriteName:String;
    public var data:WeaponLayerData;
    
    // Locations to which the children tie and the children themselves
    public var children:Array<Pair<Point, WeaponLayer>> = [];
    
    public function new(n:String, m:StringMap<WeaponLayerData>) {
        spriteName = n;
        data = m.get(spriteName);
    }
}
