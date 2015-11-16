package weapon.projectile;

import box2D.dynamics.B2Body;
import game.damage.DamageExplosion;
import weapon.Weapon;
import game.GameState;
import game.Entity;
import game.PhysicsController;

class LargeProjectile extends Projectile {
    public var body:B2Body;
    public var timeLeft:Float;

    public function new(d:ProjectileData, e:Entity) {
        super(d, e);
    }
    
    override public function buildBehavior():Void {
        fUpdatePostPhysics = updateFromBody;
        fOnHit = onHitDeath;
        fOnDeath = onHitExplode;
    }
    override public function initPhysics(phys:PhysicsController):Void {
        phys.initLargeProjectile(this, position.x, position.y, velocity.x, velocity.y);
    }
    
    public function updateTimedDeath(dt:Float, state:GameState):Void {
        timeLeft -= dt;
        killFlag = timeLeft < 0;
    }
    
    public function onHitDeath(state:GameState):Void {
        killFlag = true;
    }
    public function onHitStartTimer(state:GameState):Void {
        fUpdate = updateTimedDeath;
    }
    
    public function updateFromBody(dt:Float, state:GameState):Void {
        position.setV(body.getPosition());
        velocity.setV(body.getLinearVelocity());
    }
    
    public function onHitExplode(state:GameState):Void {
        var damage:DamageExplosion = new DamageExplosion(this);
        setupDamage(damage);
        damage.x = position.x;
        damage.y = position.y;
        damage.radius = data.explosiveRadius;
        state.damage.push(damage);
        
        // Remove from the physics world
        body.m_world.destroyBody(body);
        killFlag = true;
    }
}