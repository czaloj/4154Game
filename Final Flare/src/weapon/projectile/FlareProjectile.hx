package weapon.projectile;

import game.Entity;
import game.GameState;

class FlareProjectile extends LargeProjectile {
    public function new(d:ProjectileData, e:Entity) {
        super(d, e);
    }
    
    override public function buildBehavior():Void {
        super.buildBehavior();
        fOnDeath = onDeathEmitFlare;
    }
    
    public function onDeathEmitFlare(state:GameState):Void {
        // TODO: Add flare event
    }
}