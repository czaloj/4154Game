package weapon.projectile;

import box2D.common.math.B2Vec2;
import game.Entity;
import game.GameState;

class Projectile {
    public var data:ProjectileData;
    public var source:Entity;
    
    public var position:B2Vec2 = new B2Vec2();
    public var velocity:B2Vec2 = new B2Vec2();
    
    public var fUpdate:Float->GameState->Void;
    public var fOnHit:GameState->Void;
    
    public function new(d:ProjectileData, e:Entity) {
        data = d;
        source = e;
        buildBehavior();
    }
    
    public function update(dt:Float, state:GameState):Void {
        fUpdate(dt, state);
    }

    public function buildBehavior():Void {
        fUpdate = nullUpdate;
        fOnHit = nullOnHit;
    }

    public function nullUpdate(dt:Float, state:GameState):Void {
        // Empty
    }
    public function nullOnHit(state:GameState):Void {
        // Empty
    }
}
