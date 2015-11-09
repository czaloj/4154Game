package game.damage;

import game.damage.DamageDealer;
import weapon.projectile.LargeProjectile;

class DamageExplosion extends DamageDealer {
    public var x:Float;
    public var y:Float;
    public var radius:Float;
    public var projectile:LargeProjectile;
    
    public function new(p:LargeProjectile) {
        projectile = p;
        super(DamageDealer.TYPE_RADIAL_EXPLOSION);
    }
    
    override public function copyInto(d:DamageDealer):DamageDealer {
        var v:DamageExplosion = cast(super.copyInto(d), DamageExplosion);
        v.x = x;
        v.y = y;
        v.radius = radius;
        return v;
    }
}
