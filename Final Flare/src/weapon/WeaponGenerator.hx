package weapon;

import game.ColorScheme;
import game.damage.DamageBullet;
import game.damage.DamageExplosion;
import graphics.SpriteSheetRegistry;
import haxe.ds.ObjectMap;
import haxe.ds.StringMap;
import haxe.macro.Expr.Position;
import openfl.display.Bitmap;
import starling.display.DisplayObject;
import openfl.geom.Matrix;
import openfl.geom.Point;
import starling.display.Image;
import starling.display.Sprite;
import starling.textures.Texture;
import weapon.projectile.LargeProjectile;
import weapon.projectile.BulletProjectile;
import openfl.display.BitmapData;
import openfl.geom.Rectangle;
import openfl.utils.ByteArray;
import weapon.projectile.ProjectileData;
import weapon.WeaponData.FiringMode;
import weapon.WeaponData.ProjectileOrigin;
import weapon.WeaponGenerator.WeaponBuildWorkspace;
import weapon.WeaponPart.ProjectileExitData;

class WeaponBuildWorkspace {
    public var accuracyModifier:Float = 1.0; // (Closer to 0 is more accurate)
    public var velocityMultiplier:Float = 1.0; // (Multiplies the velocities of all projectiles)
    public var schemes:Array<ColorScheme> = [];
    
    public function new() {
        // Empty
    }
}

class WeaponGenerator {
    public static inline var GUN_SCALE:Float = 32.0;
    
    // Alpha mask levels for color generation
    public static var ALPHA_LEVEL_TRUE_COLOR:UInt = 101;
    public static var ALPHA_LEVEL_TEXTURE:UInt = 81;
    public static var ALPHA_LEVEL_PRIMARY:UInt = 61;
    public static var ALPHA_LEVEL_SECONDARY:UInt = 41;
    public static var ALPHA_LEVEL_TERTIARY:UInt = 21;
    public static var ALPHA_LEVEL_INVISIBLE:UInt = 0;

    public static function buildFromParts(l:WeaponLayer):WeaponData {
        var w:WeaponBuildWorkspace = new WeaponBuildWorkspace();
        var d:WeaponData = new WeaponData();
        d.layer = l;
        
        // Perform the transform hierarchy
        buildTransforms(l, w, new Matrix());
        
        // Generate weapon values
        traverseProperties(l, d, w);
        
        // Choose random color scheme
        d.colorScheme = w.schemes[Std.int(Math.random() * w.schemes.length)];
        
        // Make sure absurd values don't pop up
        d.reloadTime = Math.max(0, d.reloadTime);
        d.useCapacity = Std.int(Math.max(0.1, d.useCapacity));
        d.usesPerActivation = Std.int(Math.max(0.1, d.usesPerActivation));
        
        // Scale down projectile transforms and apply modifiers
        for (po in d.projectileOrigins) {
            po.exitAngle *= w.accuracyModifier;
            po.velocity *= w.velocityMultiplier;
            po.transform.tx /= GUN_SCALE;
            po.transform.ty /= -GUN_SCALE;
        }
        
        return d;
    }
    private static function buildTransforms(l:WeaponLayer, w:WeaponBuildWorkspace, parent:Matrix):Void {
        l.wsTransform = parent.clone();
        l.wsTransform.translate(-l.part.offX, -l.part.offY);
        for (c in l.children) {
            var ct:Matrix = l.wsTransform.clone();
            var wpc:WeaponPartChild = l.part.children[c.first];
            ct.translate(wpc.x, wpc.y);
            buildTransforms(c.second, w, ct);
        }
    }
    private static function traverseProperties(l:WeaponLayer, d:WeaponData, w:WeaponBuildWorkspace):Void {
        w.schemes = w.schemes.concat(l.part.schemes);
        for (p in l.part.properties) {
            switch (p.type) {
                case WeaponPropertyType.ACTIVATION_COOLDOWN:
                    d.activationCooldown = Math.max(d.activationCooldown, p.value);
                case WeaponPropertyType.BURST_COUNT:
                    d.burstCount = p.value;
                case WeaponPropertyType.BURST_PAUSE:
                    d.burstPause = Math.max(d.burstPause, p.value);
                case WeaponPropertyType.FIRING_MODE:
                    d.firingMode = p.value;
                case WeaponPropertyType.PROJECTILE_ORIGIN:
                    var po:ProjectileOrigin = new ProjectileOrigin();
                    
                    // This is only added by a barrel, so the exit angle and velocity must be somewhere here
                    var exitData:ProjectileExitData = Lambda.find(l.part.properties, function(p:WeaponProperty):Bool { return p.type == WeaponPropertyType.EXIT_INFORMATION; } ).value;
                    po.exitAngle = exitData.angle;
                    po.velocity = exitData.velocity;
                    po.projectileData = p.value;
                    
                    var tranform:Matrix = l.wsTransform.clone();
                    tranform.translate(exitData.offX, exitData.offY);
                    var rotation:Matrix = new Matrix(exitData.dirX, exitData.dirY, -exitData.dirY, exitData.dirX);
                    po.transform.concat(rotation);
                    po.transform.concat(tranform);
                    
                    d.projectileOrigins.push(po);
                case WeaponPropertyType.RELOAD_TIME:
                    d.reloadTime += p.value;
                case WeaponPropertyType.USES_PER_ACTIVATION:
                    d.usesPerActivation += p.value;
                case WeaponPropertyType.USE_CAPACITY:
                    d.useCapacity += p.value;
                default:
                    // Unknown or unused property
            }
        }
        
        // Traverse properties of children
        for (c in l.children) traverseProperties(c.second, d, w);
    }
    
    public static function buildSprite(data:WeaponData, bmpGuns:BitmapData):DisplayObject {
        var sprite:Sprite = new Sprite();
        
        // Get the fitting rectangle of the gun
        var min:Point = new Point(1000, 1000);
        var max:Point = new Point(-1000, -1000);
        
        var layers:Array<WeaponLayer> = [];
        traverseLayersToList(data.layer, layers);
        for (l in layers) {
            if (l.wsTransform.tx < min.x) min.x = l.wsTransform.tx;
            if (l.wsTransform.ty < min.y) min.y = l.wsTransform.ty;
            if (l.wsTransform.tx + l.part.w > max.x) max.x = l.wsTransform.tx + l.part.w;
            if (l.wsTransform.ty + l.part.h > max.y) max.y = l.wsTransform.ty + l.part.h;
        }
        
        var bmp:BitmapData = new BitmapData(Std.int(max.x - min.x), Std.int(max.y - min.y), true, 0x00000000);
        for (l in layers) {
            var convertedData:ByteArray = convertColors(bmpGuns, new Rectangle(l.part.sx, l.part.sy, l.part.w, l.part.h), data.colorScheme);
            var bmpTMP = new BitmapData(l.part.w, l.part.h, true, 0x00000000);
            bmpTMP.setPixels(bmpTMP.rect, convertedData);
            bmp.draw(bmpTMP, new Matrix(1, 0, 0, 1, l.wsTransform.tx - min.x, l.wsTransform.ty - min.y), null, null, null, false);
            //bmp.copyPixels(bmpTMP, bmpTMP.rect, new Point(l.wsTransform.tx - min.x, l.wsTransform.ty - min.y), null, null, true);
        }
        
        sprite.scaleX = 1 / GUN_SCALE;
        sprite.scaleY = 1 / -GUN_SCALE;
        var image:Image = new Image(Texture.fromBitmapData(bmp));
        image.x = min.x;
        image.y = min.y;
        sprite.addChild(image);
        return sprite;
    }
    private static function traverseLayersToList(l:WeaponLayer, a:Array<WeaponLayer>):Void {
        a.push(l);
        for (c in l.children) traverseLayersToList(c.second, a);
    }
    
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
        else if (data.shadynessCost == 2){
            // Example flare gun
            var pd:ProjectileData = new ProjectileData(ProjectileData.TYPE_FLARE);
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
        } else {
            // Example melee
            var pd:ProjectileData = new ProjectileData(ProjectileData.TYPE_MELEE);
            pd.damage = 10;
            pd.damageFriendly = 0;
            data.projectileOrigins[0].projectileData = pd;
            data.projectileOrigins[0].velocity = 0;
        }

        data.projectileOrigins[0].transform.translate(0.8, 0.1);
        return data;
    }

    public static function generateInitialWeapons():Array<WeaponData> {
        var weapons:Array<WeaponData> = [];

        // Temp variables
        var po:ProjectileOrigin = null;
        var w:WeaponData = null;
        var pd:ProjectileData = null;
        var l:WeaponLayer = null;

        // Rifle
        w = new WeaponData();
        w.name = "M34 Sport Rifle";
        w.colorScheme = new ColorScheme(0xff0000, 0x00ff00, 0x0000ff, 0, 0, 1, 1);
        w.evolutionCost = 0;
        w.historicalCost = 0;
        w.shadynessCost = 0;
        w.firingMode = FiringMode.AUTOMATIC;
        w.useCapacity = 34;
        w.usesPerActivation = 1;
        w.reloadTime = 2.4;
        w.activationCooldown = 0.15;
        w.burstPause = 0;
        w.burstCount = 0;
        w.projectileOrigins = [];
        po = new ProjectileOrigin();
        po.exitAngle = 0.3;
        pd = new ProjectileData(ProjectileData.TYPE_BULLET);
        pd.damage = 10;
        pd.damageFriendly = 0;
        pd.penetrationCount = 0;
        pd.gravityAcceleration = 0.0;
        po.projectileData = pd;
        po.velocity = 1500;
        po.transform.translate(0.8, 0.1);
        w.projectileOrigins.push(po);
        weapons.push(w);

        // Grenade launcher
        w = new WeaponData();
        w.name = "Junk'n'Chuck";
        w.colorScheme = new ColorScheme(0xff0000, 0x00ff00, 0x0000ff, 0, 0, 1, 1);
        w.evolutionCost = 0;
        w.historicalCost = 0;
        w.shadynessCost = 0;
        w.firingMode = FiringMode.SINGLE;
        w.useCapacity = 6;
        w.usesPerActivation = 1;
        w.reloadTime = 4.0;
        w.activationCooldown = 1.0;
        w.burstPause = 0;
        w.burstCount = 0;
        w.projectileOrigins = [];
        po = new ProjectileOrigin();
        po.exitAngle = 0.3;
        pd = new ProjectileData(ProjectileData.TYPE_LARGE);
        pd.damage = 40;
        pd.damageFriendly = 20;
        pd.timer = 0.5;
        pd.explosiveRadius = 2.0;
        pd.radius = 0.2;
        po.projectileData = pd;
        po.velocity = 30;
        po.transform.translate(0.8, 0.1);
        w.projectileOrigins.push(po);
        weapons.push(w);

        // Flare gun
        w = new WeaponData();
        w.name = "Rescue Flare Gun";
        w.colorScheme = new ColorScheme(0xff0000, 0x00ff00, 0x0000ff, 0, 0, 1, 1);
        w.evolutionCost = 0;
        w.historicalCost = 0;
        w.shadynessCost = 0;
        w.firingMode = FiringMode.SINGLE;
        w.useCapacity = 1;
        w.usesPerActivation = 1;
        w.reloadTime = 10.0;
        w.activationCooldown = 0.15;
        w.burstPause = 0;
        w.burstCount = 0;
        w.projectileOrigins = [];
        po = new ProjectileOrigin();
        po.exitAngle = 0.3;
        pd = new ProjectileData(ProjectileData.TYPE_FLARE);
        pd.damage = 0;
        pd.damageFriendly = 0;
        pd.timer = 3.0;
        pd.explosiveRadius = 1.0;
        pd.radius = 0.05;
        po.projectileData = pd;
        po.velocity = 15;
        po.transform.translate(0.8, 0.1);
        w.projectileOrigins.push(po);
        weapons.push(w);

        return weapons;
    }

    public function new() {
        // Empty
    }

    public static function convertColors(bmp:BitmapData, rect:Rectangle, scheme:ColorScheme):ByteArray {
        // Get original pixels
        bmp.lock();
        var pixels:ByteArray = bmp.getPixels(rect);

        // Create output stream
        var nba:ByteArray = new ByteArray();
        nba.length = pixels.length;
        nba.position = 0;

        // Traverse and convert color values
        pixels.position = 0;
        var i:UInt = 0;
        while (i < (pixels.length / 4)) {
            var argb:UInt = pixels.readUnsignedInt();
            argb = buildColor((argb >> 24) & 0xff, (argb >> 16) & 0xff, (argb >> 8) & 0xff, argb & 0xff, scheme);
            nba.writeUnsignedInt(argb);
            i++;
        }

        // Unlock for others
        bmp.unlock();
        nba.position = 0;
        return nba;
    }
    private static function buildColor(a:UInt, r:UInt, g:UInt, b:UInt, scheme:ColorScheme):UInt {
        if (a > ALPHA_LEVEL_TRUE_COLOR) {
            return (a << 24) | (r << 16) | (g << 8) | b;
        } else if (a < ALPHA_LEVEL_TERTIARY) {
            return 0x00000000;
        } else {
            var schemeColor:UInt = 0xffff00ff;
            if (a > ALPHA_LEVEL_TEXTURE) {
                // TODO: Texture
            } else if (a > ALPHA_LEVEL_PRIMARY) {
                schemeColor = scheme.primary;
            } else if (a > ALPHA_LEVEL_SECONDARY) {
                schemeColor = scheme.secondary;
            } else {
                schemeColor = scheme.tertiary;
            }

            var fa:Float = (schemeColor >> 24) & 0xff;
            var fr:Float = (schemeColor >> 16) & 0xff;
            var fg:Float = (schemeColor >> 8) & 0xff;
            var fb:Float = schemeColor & 0xff;
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
            return (ca << 24) | (cr << 16) | (cg << 8) | cb;
        }
    }

    public static function composeLayers():Void {
        var bmpTint:BitmapData = null;
        var bmpOpacity:BitmapData = null;
        var bmpColor:BitmapData = null;
        var bmpAlpha:BitmapData = null;
        QuickIO.loadBitmap(function (o:BitmapData):Void { bmpTint = o;
        QuickIO.loadBitmap(function (o:BitmapData):Void { bmpOpacity = o;
        QuickIO.loadBitmap(function (o:BitmapData):Void { bmpColor = o;
        QuickIO.loadBitmap(function (o:BitmapData):Void { bmpAlpha = o;

        var rect:Rectangle = new Rectangle(0, 0, bmpTint.width, bmpTint.height);

        // Get original pixels
        bmpTint.lock();
        var pixelsTint:ByteArray = bmpTint.getPixels(rect);
        bmpOpacity.lock();
        var pixelsOpacity:ByteArray = bmpOpacity.getPixels(rect);
        bmpColor.lock();
        var pixelsColor:ByteArray = bmpColor.getPixels(rect);
        bmpAlpha.lock();
        var pixelsAlpha:ByteArray = bmpAlpha.getPixels(rect);

        // Create output stream
        var nba:ByteArray = new ByteArray();
        nba.length = pixelsTint.length;
        nba.position = 0;

        // Traverse and convert color values
        pixelsTint.position = 0;
        pixelsOpacity.position = 0;
        pixelsColor.position = 0;
        pixelsAlpha.position = 0;
        var i:UInt = 0;
        while (i < (pixelsTint.length / 4)) {
            var argbTint:UInt = pixelsTint.readUnsignedInt();
            var argbOpacity:UInt = pixelsOpacity.readUnsignedInt();
            var argbColor:UInt = pixelsColor.readUnsignedInt();
            var argbAlpha:UInt = pixelsAlpha.readUnsignedInt();

            var argb:UInt = ((argbTint & 0x00ff0000) | (argbOpacity & 0x0000ff00) | (argbColor & 0x00ffffff)) | ((argbAlpha & 0x00ff0000) << 8);
            nba.writeUnsignedInt(argb);
            i++;
        }

        // Unlock for others
        bmpTint.unlock();
        bmpOpacity.unlock();
        bmpColor.unlock();
        bmpAlpha.unlock();
        nba.position = 0;

        // Save pixels in new bitmap
        var bmp:BitmapData = new BitmapData(bmpTint.width, bmpTint.height, true, 0x00000000);
        bmp.setPixels(new Rectangle(0, 0, bmp.width, bmp.height), nba);
        QuickIO.saveBitmap(bmp);
        } );} );} );} );
    }
}
