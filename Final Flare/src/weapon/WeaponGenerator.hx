package weapon;

import game.ColorScheme;
import game.damage.DamageBullet;
import game.Projectile;
import openfl.display.BitmapData;
import openfl.geom.Rectangle;
import openfl.utils.ByteArray;
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
        data.useCapacity = 10;
        data.usesPerActivation = 1;
        data.reloadTime = 5;
        data.activationCooldown = 0.25;
        data.burstPause = 0;
        data.burstCount = 0;
        
        data.projectileOrigins = [
            new ProjectileOrigin()
        ];
        data.projectileOrigins[0].exitAngle = 0.3;
        var damage:DamageBullet = new DamageBullet(null);
        damage.damage = 10;
        damage.friendlyDamage = 0;
        damage.piercingAmount = 0;
        data.projectileOrigins[0].projectile = new Projectile(damage);
        data.projectileOrigins[0].transform.translate(0.4, 0.1);
        data.projectileOrigins[0].velocity = 1500;
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
