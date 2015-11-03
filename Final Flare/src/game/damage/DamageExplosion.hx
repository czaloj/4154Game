package game.damage;
import game.damage.DamageDealer;

class DamageExplosion extends DamageDealer {
    public var x:Float;
    public var y:Float;
    public var radius:Float;
    
    public function new() {
        super(DamageDealer.TYPE_RADIAL_EXPLOSION);
    }
    
    override public function copyInto(d:DamageDealer):DamageDealer {
        var damage:DamageExplosion = cast(super.copyInto(d), DamageExplosion);
        damage.x = x;
        damage.y = y;
        damage.radius = radius;
        return damage;
    }
}
