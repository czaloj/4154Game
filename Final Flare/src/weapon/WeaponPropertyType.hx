package weapon;

class WeaponPropertyType {
    // Constructed from normal part data
    public static var PART_TYPE:Int = 0; // Enum
    public static var CHILDREN_REQUIRED:Int = 1; // Int
    public static var TOTAL_CHILDREN:Int = 2; // Int
    public static var SUB_CLASS:Int = 3; // String
    
    // Used to construct weapon data
    public static var FIRE_RATE:Int = 4; // Float
    public static var RELOAD_TIME:Int = 5; // Float
    public static var FIRING_MODE:Int = 6; // Enum
    public static var USE_CAPACITY:Int = 7; // Int
    public static var USES_PER_ACTIVATION:Int = 8; // Int
    public static var ACTIVATION_COOLDOWN:Int = 9; // Float
    public static var BURST_PAUSE:Int = 10; // Float
    public static var BURST_COUNT:Int = 11; // Int
    public static var PROJECTILE_DATA:Int = 12; // ProjectileOrigin Data
    public static var DAMAGE_POLYGON:Int = 13; // Polygon Data
    public static var EXIT_INFORMATION:Int = 14; // Contains angle, velocity, and origin and direction
    public static var PROJECTILE_VELOCITY_MULTIPLIER:Int = 15; // Float
    public static var ACCURACY_MODIFIER:Int = 16; // Float
    public static var IS_BASE:Int = 17; // Bool
    public static var DAMAGE_INCREASE:Int = 18; // Int
    
    // Feedback information
    public static var ANIMATION_RELOAD:Int = 19; // String
    public static var ANIMATION_FIRE:Int = 20; // String
    
    public function new() {
        
    }
}
