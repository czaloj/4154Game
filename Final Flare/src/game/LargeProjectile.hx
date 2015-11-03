package game;

import box2D.dynamics.B2Body;
import game.damage.DamageExplosion;

class LargeProjectile {
    public var body:B2Body;
    public var fOnHit:GameState->Void;
    
    public function new() {
        
    }
    
    public function onHitExplode(state:GameState):Void {
        var damage:DamageExplosion = new DamageExplosion();
        damage.
    }
}