package game.damage;

class DamageBullet extends DamageDealer {
    public static inline var TIME_TO_LIVE:Float = 0.3;
    
    public var piercingAmount:Int;
    
    public var originX:Float;
    public var originY:Float;
    public var velocityX:Float;
    public var velocityY:Float;
    
    public var knockbackAmount:Float;
    
    public function new() {
        super(DamageDealer.TYPE_BULLET);
    }
}
