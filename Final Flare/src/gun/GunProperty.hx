package gun;

class GunProperty {
    public var type:GunPropertyType;
    public var valueInt:Int;
    public var valueFloat:Float;
    
    public function new(t:GunPropertyType, v:Int) {
        type = t;
        valueInt = v;
    }
    public function new(t:GunPropertyType, v:Float) {
        type = t;
        valueFloat = v;
    }
}
