package game;
import game.damage.DamageBullet;

enum Type {
    BULLET;
    BODY;
}

class Projectile extends Entity {
    private static var BULLET_SPEED:Float = 20;

    public var type:Type;
    public var penetrationsLeft:Int;
    public var gravityScale:Float;
    public var damage:DamageBullet;
    
    public function new(d:DamageBullet) {
       super();
       damage = new DamageBullet();
       damage.damage = d.damage;
       damage.friendlyDamage = d.friendlyDamage;
       damage.knockbackAmount = d.knockbackAmount;
       damage.piercingAmount = d.piercingAmount;
       damage.teamDestinationFlags = d.teamDestinationFlags;
       damage.teamSourceFlags = d.teamSourceFlags;
    }
    
    public function update(dt:Float, s:GameState):Void {
    }
}
