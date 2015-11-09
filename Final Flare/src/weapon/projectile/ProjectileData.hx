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
    // The projectiles that this one can spawn either after X time, X collisions, or some other predication
    public var children:Array<ProjectileChildData> = [];
    
    // Bullet information
    public var penetrationCount:Int = -1; // -1 For single penetration, 0 for full penetration, N >= 1 for N penetrations
    
    // Explosive information
    public var timer:Float; // Amount of time alive either after spawn or after it's collided a certain amount of times
    public var collisionCount:Int; // Number of times projectile is allowed to collide
    
    // Melee information
    public var damageShape:B2Shape;
    
    public function new() {
        // Empty
    }

    public function constructProjectile(origin:Point, velocity:Point, source:Entity):Projectile { 
        
    }
}
