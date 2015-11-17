package weapon;

import game.ColorScheme;
import weapon.projectile.LargeProjectile;
import weapon.projectile.BulletProjectile;
import openfl.geom.Matrix;
import openfl.geom.Point;
import weapon.projectile.ProjectileData;

enum FiringMode {
    SINGLE;
    BURST;
    AUTOMATIC;
}

class ProjectileOrigin {
    // Transform relative to the gun
    public var transform:Matrix = new Matrix();
    
    // Velocity relative to the gun
    public var velocity:Float;
    
    // The variance in angle which a projectile can undergo (FOV angle)
    public var exitAngle:Float;
    
    // Projectile to be generated
    public var projectileData:ProjectileData;
    
    public function new() {
        // Empty
    }
}

class WeaponData {
    public var name:String;
    public var colorScheme:ColorScheme;
    
    public var evolutionCost:Int;
    public var historicalCost:Int;
    public var shadynessCost:Int;
    
    public var projectileOrigins:Array<ProjectileOrigin> = [];
    
    public var properties:Array<WeaponProperty> = [];
    
    
    // Information for firing logic
    public var firingMode:FiringMode;
    public var useCapacity:Int;
    public var usesPerActivation:Int;
    public var reloadTime:Float;
    public var activationCooldown:Float;
    public var burstPause:Float;
    public var burstCount:Int;
    
    // The root weapon layer
    public var layer:WeaponLayer;
    
    public function new() {
        // Empty
    }
}
