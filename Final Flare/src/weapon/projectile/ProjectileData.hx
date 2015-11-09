package weapon.projectile;

import box2D.collision.shapes.B2Shape;
import game.Entity;
import openfl.geom.Matrix;
import openfl.geom.Point;

class ProjectileChildData {
    public var offset:Matrix;
    public var data:ProjectileData;
    
    public function new() {
        // Empty
    }
}

class ProjectileData {
    public static inline var TYPE_BULLET = 1;
    public static inline var TYPE_LARGE = 2;
    
    // The projectiles that this one can spawn either after X time, X collisions, or some other predication
    public var children:Array<ProjectileChildData> = [];
    
    public var constructionType:Int = TYPE_BULLET;
    
    public var damage:Int = 1;
    public var damageFriendly:Int = 1;
    public var hitFriendly:Bool = false;
    
    // Bullet information
    public var penetrationCount:Int = -1; // -1 For single penetration, 0 for full penetration, N >= 1 for N penetrations
    public var gravityAcceleration:Float = 0.0;

    // Large projectile information
    public var timer:Float; // Amount of time alive either after spawn or after it's collided a certain amount of times
    public var radius:Float; // Radius of the projectile
    public var collisionCount:Int; // Number of times projectile is allowed to collide

    // Explosive information
    public var explosiveRadius:Float;
    
    // Melee information
    public var damageShape:B2Shape;
    
    public function new(t:Int) {
        constructionType = t;
    }

    public function constructProjectile(origin:Point, velocity:Point, source:Entity):Projectile {
        var projectile:Projectile = (switch (constructionType) {
            case TYPE_BULLET: new BulletProjectile(this, source);
            case TYPE_LARGE: new LargeProjectile(this, source);
            case _: null;
        });
        projectile.buildBehavior();
        projectile.position.set(origin.x, origin.y);
        projectile.velocity.set(velocity.x, velocity.y);
        return projectile;
    }
}
