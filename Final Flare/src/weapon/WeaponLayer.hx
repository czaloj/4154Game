package weapon;

import openfl.geom.Point;
import openfl.geom.Matrix;

class WeaponLayer {
    // The sprite used for this part
    public var part:WeaponPart;
    
    // Locations to which the children tie and the children themselves
    public var children:Array<Pair<Int, WeaponLayer>> = [];
    
    public var wsTransform:Matrix = new Matrix(); // Tranformation of this part in the weapon's space
    
    public function new(n:String, c:Array<Pair<Int, WeaponLayer>> = null) {
        part = PartRegistry.parts.get(n);
        if (c != null) {
            for (child in c) {
                children.push(new Pair<Int, WeaponLayer>(child.first, child.second));
            }
        }
    }
}
