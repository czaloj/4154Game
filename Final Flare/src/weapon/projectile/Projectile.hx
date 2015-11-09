package weapon.projectile;

import game.GameState;

class Projectile {
    public var data:ProjectileData;
    public var fUpdate:Float->GameState->Void;
    public var fOnHit:GameState->Void;
    
    public function new(d:ProjectileData) {
        data = d;
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
