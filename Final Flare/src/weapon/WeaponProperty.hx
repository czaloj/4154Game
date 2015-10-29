package weapon;

class WeaponProperty {
    public var type:WeaponPropertyType;
    public var value:Dynamic;
    
    public function new(t:WeaponPropertyType, v:Dynamic) {
        type = t;
        value = v;
    }
}
