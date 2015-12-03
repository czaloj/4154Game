package weapon;

enum WeaponPropertyType {
    // Constructed from normal part data
    PART_TYPE; // Enum
    CHILDREN_REQUIRED; // Int
    TOTAL_CHILDREN; // Int
    SUB_CLASS; // String
    
    // Used to construct weapon data
    FIRE_RATE; // Float
    RELOAD_TIME; // Float
    FIRING_MODE; // Enum
    USE_CAPACITY; // Int
    USES_PER_ACTIVATION; // Int
    ACTIVATION_COOLDOWN; // Float
    BURST_PAUSE; // Float
    BURST_COUNT; // Int
    PROJECTILE_DATA; // ProjectileOrigin Data
    EXIT_INFORMATION; // Contains angle, velocity, and origin and direction
    PROJECTILE_VELOCITY_MULTIPLIER; // Float
    ACCURACY_MODIFIER; // Float
    IS_BASE; // Bool
}
