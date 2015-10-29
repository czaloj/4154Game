package weapon;

class WeaponStats {
    public var fireRate:Float; // The amount of time in seconds between successive shots
    public var reloadTime:Float; // Amount of time in seconds to reload once all shots have been fired
    public var fireMode:FiringMode;
    
    public function new() {
        // Empty
    }
}
