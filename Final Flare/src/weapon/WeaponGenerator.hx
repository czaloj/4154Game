package weapon;

import game.ColorScheme;
import game.damage.DamageBullet;
import game.damage.DamageExplosion;
import weapon.projectile.LargeProjectile;
import weapon.projectile.BulletProjectile;
import openfl.display.BitmapData;
import openfl.geom.Rectangle;
import openfl.utils.ByteArray;
import weapon.projectile.ProjectileData;
import weapon.WeaponData.FiringMode;
import weapon.WeaponData.ProjectileOrigin;

class WeaponGenerator {
    // Alpha mask levels for color generation
    public static var ALPHA_LEVEL_TRUE_COLOR:UInt = 21;
    public static var ALPHA_LEVEL_TEXTURE:UInt = 16;
    public static var ALPHA_LEVEL_PRIMARY:UInt = 11;
    public static var ALPHA_LEVEL_SECONDARY:UInt = 6;
    public static var ALPHA_LEVEL_TERTIARY:UInt = 1;
    public static var ALPHA_LEVEL_INVISIBLE:UInt = 0;
    
    public static function generate(params:WeaponGenParams):WeaponData {
        var data:WeaponData = new WeaponData();

        // TODO: Generate a real gun
        data.name = "Gun";
        data.colorScheme = new ColorScheme(0xff0000, 0x00ff00, 0x0000ff, 0, 0, 1, 1);
        data.evolutionCost = params.evolutionPoints;
        data.historicalCost = params.historicalPoints;
        data.shadynessCost = params.shadynessPoints;
        
        data.firingMode = FiringMode.AUTOMATIC;
        data.useCapacity = 36;
        data.usesPerActivation = 1;
        data.reloadTime = 2.4;
        data.activationCooldown = 0.15;
        data.burstPause = 0;
        data.burstCount = 0;
        
        data.projectileOrigins = [
            new ProjectileOrigin()
        ];
        data.projectileOrigins[0].exitAngle = 0.3;
        if (data.shadynessCost == 0) {
            // Example conventional gun
            var pd:ProjectileData = new ProjectileData(ProjectileData.TYPE_BULLET);
            pd.damage = 10;
            pd.damageFriendly = 0;
            pd.penetrationCount = 0;
            pd.gravityAcceleration = 0.0;
            data.projectileOrigins[0].projectileData = pd;
            data.projectileOrigins[0].velocity = 1500;            
        }
        else if (data.shadynessCost == 1) {
            // Example grenade launcher
            var pd:ProjectileData = new ProjectileData(ProjectileData.TYPE_LARGE);
            pd.damage = 40;
            pd.damageFriendly = 20;
            pd.timer = 0.5;
            pd.explosiveRadius = 2.0;
            pd.radius = 0.2;
            data.projectileOrigins[0].projectileData = pd;
            data.projectileOrigins[0].velocity = 30;
        }
        else {
            // Example flare gun
            var pd:ProjectileData = new ProjectileData(ProjectileData.TYPE_LARGE);
            pd.damage = 0;
            pd.damageFriendly = 0;
            pd.timer = 3.0;
            pd.explosiveRadius = 1.0;
            pd.radius = 0.05;
            data.projectileOrigins[0].projectileData = pd;
            data.projectileOrigins[0].velocity = 15;
            data.reloadTime = 10.0;
            data.useCapacity = 1;
            data.firingMode = FiringMode.SINGLE;
        }
        data.projectileOrigins[0].transform.translate(0.8, 0.1);
        return data;
    }

    public function new() {
        // Empty
    }

    private static function convertColors(bmp:BitmapData, rect:Rectangle, scheme:ColorScheme):ByteArray {
        // Get original pixels
        bmp.lock();
        var pixels:ByteArray = bmp.getPixels(rect);
        
        // Create output stream
        var nba:ByteArray = new ByteArray();
        nba.length = pixels.length;
        nba.position = 0;

        // Traverse and convert color values
        var i:UInt = 0;
        while (i < (pixels.length * 4)) {
            var rgba:UInt = pixels.readUnsignedInt();
            rgba = buildColor((rgba >> 24) & 0xff, (rgba >> 16) & 0xff, (rgba >> 8) & 0xff, rgba & 0xff, scheme);
            nba.writeUnsignedInt(rgba);
            i++;
        }
        
        // Unlock for others
        bmp.unlock();
        return nba;
    }
    private static function buildColor(r:UInt, g:UInt, b:UInt, a:UInt, scheme:ColorScheme):UInt {
        if (a > ALPHA_LEVEL_TRUE_COLOR) {
            return (r << 24) | (g << 16) | (b << 8) | a;
        } else if (a == ALPHA_LEVEL_INVISIBLE) {
            return 0x00000000;
        } else {
            var schemeColor:UInt = 0xff00ffff;
            if (a > ALPHA_LEVEL_TEXTURE) {
                // TODO: Texture
            } else if (a > ALPHA_LEVEL_PRIMARY) {
                schemeColor = scheme.primary;
            } else if (a > ALPHA_LEVEL_SECONDARY) {
                schemeColor = scheme.secondary;
            } else {
                schemeColor = scheme.tertiary;
            }
            
            var fr:Float = (schemeColor >> 24) & 0xff;
            var fg:Float = (schemeColor >> 16) & 0xff;
            var fb:Float = (schemeColor >> 8) & 0xff;
            var fa:Float = schemeColor & 0xff;
            var tint = r / 128.0;
            var opacity = g / 255.0;
            fr *= tint;
            fg *= tint;
            fb *= tint;
            fa *= opacity;
            var cr:UInt = cast(Std.int(Math.min(255, Math.max(0, fr))), UInt);
            var cg:UInt = cast(Std.int(Math.min(255, Math.max(0, fg))), UInt);
            var cb:UInt = cast(Std.int(Math.min(255, Math.max(0, fb))), UInt);
            var ca:UInt = cast(Std.int(Math.min(255, Math.max(0, fa))), UInt);
            return (cr << 24) | (cg << 16) | (cb << 8) | ca;
        }
    }
}
