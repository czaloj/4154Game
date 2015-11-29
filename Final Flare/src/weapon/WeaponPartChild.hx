package weapon;

class WeaponPartChild {
    // Offset from the parent for attachment
    public var x:Int;
    public var y:Int;
    
    // Requirements
    public var isRequired:Bool = false;
    public var requirements:Array<WeaponPart->Bool> = [];

    public function new(x:Int, y:Int, required:Bool, r:Array<WeaponPart->Bool> = null) {
        this.x = x;
        this.y = y;
        isRequired = required;
        if (r != null) {
            for (v in r) requirements.push(v);
        }
    }
    
}