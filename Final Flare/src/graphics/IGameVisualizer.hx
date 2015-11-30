package graphics;

import game.Entity;
import game.GameState;
import weapon.projectile.Projectile;

interface IGameVisualizer {
    public function onEntityAdded(s:GameState, o:Entity):Void;
    public function onEntityRemoved(s:GameState, o:Entity):Void;
    public function onProjectileAdded(s:GameState, o:Projectile):Void;
    public function onProjectileRemoved(s:GameState, o:Projectile):Void;
    
    public function onBloodSpurt(sx:Float, sy:Float, dx:Float, dy:Float):Void;
    public function onExplosion(sx:Float, sy:Float, r:Float):Void;
    public function onReload(e:Entity, ox:Float, oy:Float, time:Float):Void;
    
    public function addBulletTrail(sx:Float, sy:Float, ex:Float, ey:Float, duration:Float):Void;
    public function addScreenShake(x:Float, y:Float):Void;
}
