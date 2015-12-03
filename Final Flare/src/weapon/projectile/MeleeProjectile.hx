package weapon.projectile;

import box2D.dynamics.B2Body;
import game.damage.DamageDealer;
import game.damage.DamagePolygon;
import game.Entity;
import game.PhysicsController;
import game.GameState;

class MeleeProjectile extends Projectile {
    public var body:B2Body;
    public var timeDelayed:Float = 0;
    
    public function new(d:ProjectileData, e:Entity) {
        super(d, e);
    }

    override public function buildBehavior():Void {
        timeDelayed = data.timer;
        fUpdate = updateSimple;
    }
    public function updateDelay(dt:Float, s:GameState):Void {
        timeDelayed -= dt;
        if (timeDelayed < 0) fUpdate = updateSimple;
    }
    public function updateSimple(dt:Float, s:GameState):Void {
        var d = new DamagePolygon();
        setupDamage(d);
        d.x = position.x;
        d.y = position.y;
        
        d.width = data.damageWidth;
        d.height = data.damageHeight;

        s.damage.push(d);
        killFlag = true;
    }

}
