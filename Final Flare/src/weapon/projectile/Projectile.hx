package weapon.projectile;

import box2D.common.math.B2Vec2;
import game.damage.DamageDealer;
import game.Entity;
import game.GameState;
import game.PhysicsController;

class Projectile {
    public var data:ProjectileData;
    public var source:Entity;
    
    public var position:B2Vec2 = new B2Vec2();
    public var velocity:B2Vec2 = new B2Vec2();
    
    public var fUpdate:Float->GameState->Void;
    public var fOnHit:GameState->Void;
    public var fOnDeath:GameState->Void;
    public var fUpdatePostPhysics:Float->GameState->Void;
    
    public var killFlag:Bool = false;
    
    public function new(d:ProjectileData, e:Entity) {
        data = d;
        source = e;
        
        fUpdate = nullUpdate;
        fOnHit = nullOnHit;
        fOnDeath = nullOnDeath;
        fUpdatePostPhysics = simpleUpdatePostPhysics;
        buildBehavior();
    }

    public function update(dt:Float, state:GameState):Void {
        fUpdate(dt, state);
    }
    public function updatePostPhysics(dt:Float, state:GameState):Void {
        fUpdatePostPhysics(dt, state);
    }

    public function buildBehavior():Void {
    }
    public function initPhysics(phys:PhysicsController):Void {
        // Empty
    }
    
    public function nullUpdate(dt:Float, state:GameState):Void {
        // Empty
    }
    public function nullOnHit(state:GameState):Void {
        // Empty
    }
    public function nullOnDeath(state:GameState):Void {
        // Empty
    }
    public function simpleUpdatePostPhysics(dt:Float, state:GameState):Void {
        position.x += velocity.x * dt;
        position.y += velocity.y * dt;
    }
    
    public function setupDamage(d:DamageDealer):Void {
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
    }
}
    
