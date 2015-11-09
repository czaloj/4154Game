package weapon.projectile;

import game.damage.DamageBullet;
import box2D.common.math.B2Vec2;
import game.damage.DamageDealer;
import game.Entity;
import game.PhysicsController;
import game.GameState;

class BulletProjectile extends Projectile {
    public var penetrationsLeft:Int;
    
    public function new(d:ProjectileData, e:Entity) {
        super(d, e);
        penetrationsLeft = d.collisionCount;
    }
    
    override public function buildBehavior():Void {
        fUpdate = updateSimple;
    }
    
    public function updateSimple(dt:Float, s:GameState):Void {
        velocity.y += data.gravityAcceleration * dt;
        
        var d = new DamageBullet(this);
        d.originX = position.x;
        d.originY = position.y;
        d.velocityX = velocity.x;
        d.velocityY = velocity.y;
        d.piercingAmount = penetrationsLeft;
        d.damage = data.damage;
        d.friendlyDamage = data.damageFriendly;
        
        if (source.team == Entity.TEAM_PLAYER) {
            d.teamDestinationFlags = DamageDealer.TEAM_ENEMY | (data.hitFriendly ? DamageDealer.TEAM_PLAYER : 0);
            d.teamSourceFlags = DamageDealer.TEAM_PLAYER;
        }
        else {
            d.teamDestinationFlags = DamageDealer.TEAM_PLAYER | (data.hitFriendly ? DamageDealer.TEAM_ENEMY : 0);
            d.teamSourceFlags = DamageDealer.TEAM_ENEMY;
        }
        
        s.damage.push(d);
    }
}
