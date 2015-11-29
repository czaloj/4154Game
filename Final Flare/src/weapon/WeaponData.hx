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
    
    public var evolutionCost:Int = 0;
    public var historicalCost:Int = 0;
    public var shadynessCost:Int = 0;
    
    public var projectileOrigins:Array<ProjectileOrigin> = [];
    
    public var properties:Array<WeaponProperty> = [];
    
    
    // Information for firing logic
    public var firingMode:FiringMode = FiringMode.SINGLE;
    public var useCapacity:Int = 0;
    public var usesPerActivation:Int = 0;
    public var reloadTime:Float = 0;
    public var activationCooldown:Float = 0;
    public var burstPause:Float = 0;
    public var burstCount:Int = 0;
    
    // The root weapon layer
    public var layer:WeaponLayer = null;
    
    public function new() {
        // Empty
    }
}
