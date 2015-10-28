package game.damage;

class DamageDealer {
    public static inline var TYPE_BULLET:Int = 1;
    public static inline var TYPE_RADIAL_EXPLOSION:Int = 2;
    public static inline var TYPE_COLLISION_POLYGON:Int = 3;
    
    public static inline var TEAM_PLAYER:Int = 0x1 << 0;
    public static inline var TEAM_ENEMY:Int = 0x1 << 1;
    
    public var type:Int;
    
    public var teamSourceFlags:Int; // The team that spawned this damage... if neutral, none spawned it.
    public var teamDestinationFlags:Int; // The team that should receive this damage... if neutral, all receive it.
    
    public var damage:Int; // Amount of damage to apply under normal conditions
    public var friendlyDamage:Int; // Amount of damage to apply if friendly fire occurs
    
    public function new(t:Int) {
        type = t;
    }
    
    public function damageFor(team:Int):Int {
        if ((team & teamSourceFlags) != 0) return friendlyDamage;
        else if ((team & teamDestinationFlags) != 0) return damage;
        else return 0;
    }
}