package game.damage;

import game.damage.DamageDealer;
import weapon.projectile.BulletProjectile;

class DamageBullet extends DamageDealer {
    public static inline var TIME_TO_LIVE:Float = 0.3;
    
    public var piercingAmount:Int;
    
    public var projectile:BulletProjectile;
    public var originX:Float;
    public var originY:Float;
    public var velocityX:Float;
    public var velocityY:Float;
    
    public function new(p:BulletProjectile) {
        super(DamageDealer.TYPE_BULLET);
        projectile = p;
    }
    
    override public function copyInto(d:DamageDealer):DamageDealer {
        var v:DamageBullet = cast(super.copyInto(d), DamageBullet);
        v.piercingAmount = piercingAmount;
        v.projectile = projectile;
        v.originX = originX;
        v.originY = originY;
        v.velocityX = velocityX;
        v.velocityY = velocityY;
        return v;
    }
}
