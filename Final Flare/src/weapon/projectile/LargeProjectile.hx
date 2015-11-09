package weapon.projectile;

import box2D.dynamics.B2Body;
import game.damage.DamageExplosion;
import weapon.Weapon;
import game.GameState;
import game.Entity;
import game.PhysicsController;

class LargeProjectile {
    public var body:B2Body;
    public var fOnHit:GameState->Void;
    
    public var radius:Float;
    public var explosiveDamage:DamageExplosion;
    
    public function new(d:DamageExplosion) {
        fOnHit = onHitExplode;
        explosiveDamage = cast(d.copyInto(new DamageExplosion(this)), DamageExplosion);
    }
    
    public function createCopyAt(e:Entity, x:Float, y:Float, vx:Float, vy:Float, phys:PhysicsController):LargeProjectile {
        var p:LargeProjectile = new LargeProjectile(explosiveDamage);
        p.radius = radius;
        phys.initLargeProjectile(p, x, y, vx, vy);
        p.explosiveDamage.setParent(e, true); // TODO: Friendly fire input
        return p;
    }
    
    public function onHitExplode(state:GameState):Void {
        var damage:DamageExplosion = new DamageExplosion(this);
        explosiveDamage.copyInto(damage);
        damage.x = body.getPosition().x;
        damage.y = body.getPosition().y;
        state.damage.push(damage);
        
        // Remove from the physics world
        body.m_world.destroyBody(body);
    }
}