package weapon.projectile;

import game.Entity;
import game.events.GameEventFlare;
import game.GameState;

class FlareProjectile extends LargeProjectile {
    public function new(d:ProjectileData, e:Entity) {
        super(d, e);
        
        // TODO: Get from projectile data
        timeLeft = 3.0;
    }
    
    override public function buildBehavior():Void {
        super.buildBehavior();
        fOnDeath = onDeathEmitFlare;
        fOnHit = nullOnHit;
        fUpdate = updateTimedDeath;
    }
    
    public function onDeathEmitFlare(state:GameState):Void {
        state.gameEvents.push(new GameEventFlare(position.x, position.y));
    }
}