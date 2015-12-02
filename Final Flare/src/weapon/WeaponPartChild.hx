package weapon;
import openfl.geom.Matrix;

class WeaponPartChild {
    // Offset from the parent for attachment
    public var offset:Matrix;
    public var y:Int;
    
    // Requirements
    public var isRequired:Bool = false;
    public var requirements:Array<WeaponPart->Bool> = [];

    public function new(offset:Matrix, required:Bool, r:Array<WeaponPart->Bool> = null) {
        this.offset = offset.clone();
        isRequired = required;
        if (r != null) {
            for (v in r) requirements.push(v);
        }
    }
    
}