package game;

import game.damage.DamageBullet;
import box2D.common.math.B2Vec2;

class Projectile {
    private static var BULLET_SPEED:Float = 20;

    public var position:B2Vec2 = new B2Vec2();     //Object position
    public var velocity:B2Vec2 = new B2Vec2();     //Object velocity

    public var penetrationsLeft:Int;
    public var gravityScale:Float;
    public var damage:DamageBullet;
    
    public function new(d:DamageBullet) {
        damage = new DamageBullet(this);
        damage.damage = d.damage;
        damage.friendlyDamage = d.friendlyDamage;
        damage.knockbackAmount = d.knockbackAmount;
        damage.piercingAmount = d.piercingAmount;
    }
    
    /**
     * Spawn a projectile of this type in a new position with a new velocity
     * @param e Entity that created this projectile
     * @param x Origin X
     * @param y Origin Y
     * @param vx Initial velocity X
     * @param vy Initial velocity Y
     */
    public function createCopyAt(e:Entity, x:Float, y:Float, vx:Float, vy:Float):Projectile {
        var p:Projectile = new Projectile(damage);
        p.position.set(x, y);
        p.velocity.set(vx, vy);
        p.penetrationsLeft = penetrationsLeft;
        p.gravityScale = gravityScale;
        p.damage.setParent(e, false); // TODO: Friendly fire input
        return p;
    }
    
    public function update(dt:Float, s:GameState):Void {
        damage.originX = position.x;
        damage.originY = position.y;
        damage.velocityX = velocity.x;
        damage.velocityY = velocity.y;
        s.damage.push(damage);
    }
}
