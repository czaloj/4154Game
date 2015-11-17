package weapon.projectile;

import box2D.dynamics.B2Body;
import game.damage.DamageDealer;
import game.damage.DamagePolygon;
import game.Entity;
import game.PhysicsController;
import game.GameState;

class MeleeProjectile extends Projectile {
    public var body:B2Body;
    public function new(d:ProjectileData, e:Entity) {
        super(d, e);
    }

    override public function buildBehavior():Void {
        fUpdate = updateSimple;
    }
    public function updateSimple(dt:Float, s:GameState):Void {
        velocity.y += data.gravityAcceleration * dt;

        var d = new DamagePolygon();
        setupDamage(d);
        d.x = position.x;
        d.y = position.y;
        d.width = 2;
        d.height = 1;

        s.damage.push(d);
    }

}
