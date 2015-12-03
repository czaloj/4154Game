package weapon;

import game.ColorScheme;
import game.damage.DamageBullet;
import game.damage.DamageExplosion;
import graphics.SpriteSheetRegistry;
import haxe.ds.ArraySort;
import haxe.ds.ObjectMap;
import haxe.ds.StringMap;
import haxe.macro.Expr.Position;
import haxe.macro.PositionTools;
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
import weapon.WeaponPart.DamagePolygonData;
import weapon.WeaponPart.ProjectileExitData;

class WeaponBuildWorkspace {
    public var accuracyModifier:Float = 1.0; // (Closer to 0 is more accurate)
    public var velocityMultiplier:Float = 1.0; // (Multiplies the velocities of all projectiles)
    public var schemes:Array<ColorScheme> = [];
    public var additionalDamage:Int = 0;
    
    public function new() {
        // Empty
    }
}

class WeaponGenerator {
    public static inline var GUN_SCALE:Float = 64.0;
    
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
            po.projectileData.damage += w.additionalDamage;
            po.projectileData.damageFriendly += w.additionalDamage;
            po.transform.tx /= GUN_SCALE;
            po.transform.ty /= -GUN_SCALE;
        }
        
        return d;
    }
    private static function buildTransforms(l:WeaponLayer, w:WeaponBuildWorkspace, parent:Matrix):Void {
        l.wsTransform = new Matrix(1, 0, 0, 1, -l.part.offX, -l.part.offY);
        l.wsTransform.concat(parent);
        for (c in l.children) {
            var ct:Matrix = l.part.children[c.first].offset.clone();
            ct.concat(l.wsTransform);
            buildTransforms(c.second, w, ct);
        }
    }
    private static function traverseProperties(l:WeaponLayer, d:WeaponData, w:WeaponBuildWorkspace):Void {
        d.evolutionCost += l.part.costEvolution;
        d.shadynessCost += l.part.costShadyness;
        d.historicalCost += l.part.costHistorical;
        
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
                case WeaponPropertyType.EXIT_INFORMATION:
                    var exitData:ProjectileExitData = p.value;
                    
                    // Calculate exit location of the projectile
                    var bulletExitTransform:Matrix = new Matrix(exitData.dirX, exitData.dirY, -exitData.dirY, exitData.dirX, exitData.offX, exitData.offY);
                    bulletExitTransform.concat(l.wsTransform);
                    
                    for (cl in l.children) {
                        if (cl.second.part.type == WeaponPartType.PROJECTILE) {
                            var po:ProjectileOrigin = new ProjectileOrigin();
                            
                            po.exitAngle = exitData.angle;
                            po.velocity = exitData.velocity;
                            po.transform = bulletExitTransform.clone();
                            po.projectileData = findProjectileData(cl.second);
                            
                            d.projectileOrigins.push(po);
                        }
                    }
                case WeaponPropertyType.DAMAGE_POLYGON:
                    var damagePolyData:DamagePolygonData = p.value;
                    
                    var pd:ProjectileData = new ProjectileData(ProjectileData.TYPE_MELEE);
                    pd.damage = damagePolyData.damage;
                    pd.damageFriendly = 0;
                    pd.hitFriendly = false;
                    pd.timer = damagePolyData.timeActive;
                    pd.damageWidth = damagePolyData.width;
                    pd.damageHeight = damagePolyData.height;
                    
                    var po:ProjectileOrigin = new ProjectileOrigin();
                    po.exitAngle = 0;
                    po.velocity = 0;
                    po.transform = new Matrix(1, 0, 0, 1, damagePolyData.offX, damagePolyData.offY);
                    po.transform.concat(l.wsTransform);
                    po.projectileData = pd;
                    d.projectileOrigins.push(po);
                    
                case WeaponPropertyType.RELOAD_TIME:
                    d.reloadTime += p.value;
                case WeaponPropertyType.USES_PER_ACTIVATION:
                    d.usesPerActivation += p.value;
                case WeaponPropertyType.USE_CAPACITY:
                    d.useCapacity += p.value;
                case WeaponPropertyType.DAMAGE_INCREASE:
                    w.additionalDamage += p.value;
                default:
                    // Unknown or unused property
            }
        }
        
        // Traverse properties of children
        for (c in l.children) traverseProperties(c.second, d, w);
    }
    private static function findProjectileData(l:WeaponLayer):ProjectileData {
        var pd:ProjectileData = new ProjectileData(ProjectileData.TYPE_BULLET);
        
        for (p in l.part.properties) {
            if (p.type == WeaponPropertyType.PROJECTILE_DATA) {
                var data = p.value;
                pd.collisionCount = data.collisionCount;
                pd.constructionType = data.constructionType;
                pd.damage = data.damage;
                pd.damageFriendly = data.damageFriendly;
                pd.damageShape = data.damageShape;
                pd.explosiveRadius = data.explosiveRadius;
                pd.gravityAcceleration = data.gravityAcceleration;
                pd.hitFriendly = data.hitFriendly;
                pd.penetrationCount = data.penetrationCount;
                pd.radius = data.radius;
                pd.timer = data.timer;
            }
        }
        for (cl in l.children) { 
            if (cl.second.part.type == WeaponPartType.PROJECTILE) {
                var cpd:ProjectileChildData = new ProjectileChildData();
                cpd.data = findProjectileData(cl.second);
                cpd.offset = new Matrix(1, 0, 0, 1, 0, 0);
                pd.children.push(cpd);
            }
        }
        
        return pd;
    }
    
    public static function buildSprite(data:WeaponData, bmpGuns:BitmapData):DisplayObject {
        var sprite:Sprite = new Sprite();
        
        // Get the fitting rectangle of the gun
        var min:Point = new Point(1000, 1000);
        var max:Point = new Point(-1000, -1000);
        
        var layers:Array<WeaponLayer> = [];
        traverseLayersToList(data.layer, layers);
        for (l in layers) {
            // Get min and max points of the piece
            var boxPoints:Array<Point> = [
                l.wsTransform.transformPoint(new Point(0, 0)),
                l.wsTransform.transformPoint(new Point(l.part.w, 0)),
                l.wsTransform.transformPoint(new Point(0, l.part.h)),
                l.wsTransform.transformPoint(new Point(l.part.w, l.part.h))
            ];
            for (p in boxPoints) {
                min.x = Math.min(min.x, p.x);
                min.y = Math.min(min.y, p.y);
                max.x = Math.max(max.x, p.x);
                max.y = Math.max(max.y, p.y);
            }
        }
        
        var bmp:BitmapData = new BitmapData(Std.int(max.x - min.x), Std.int(max.y - min.y), true, 0x00000000);
        for (l in layers) {
            var convertedData:ByteArray = convertColors(bmpGuns, new Rectangle(l.part.sx, l.part.sy, l.part.w, l.part.h), data.colorScheme);
            var bmpTMP = new BitmapData(l.part.w, l.part.h, true, 0x00000000);
            bmpTMP.setPixels(bmpTMP.rect, convertedData);
            if (l.part.type == WeaponPartType.PROJECTILE) {
                // TODO: Add somewhere else
            }
            else {
                var translated:Matrix = l.wsTransform.clone();
                translated.translate(-min.x, -min.y);
                bmp.draw(bmpTMP, translated, null, null, null, false);
            }
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
    
    private static function allowsCost(p:WeaponPart, params:WeaponGenParams):Bool {
        return p.costEvolution <= params.evolutionPoints && p.costHistorical <= params.historicalPoints && p.costShadyness <= params.shadynessPoints;
    }
    private static function subtractCost(p:WeaponPart, params:WeaponGenParams):Void {
        params.evolutionPoints -= p.costEvolution;
        params.historicalPoints -= p.costHistorical;
        params.shadynessPoints -= p.costShadyness;
    }
    private static function randomFromArray<T>(l:Array<T>):T {
        return l[Std.int(Math.random() * l.length)];
    }
    private static function randomFromList<T>(l:List<T>):T {
        var i:Int = Std.int(Math.random() * l.length);
        for (v in l) {
            if (i <= 0) return v;
            i--;
        }
        return null;
    }
    private static function satisfyingPart(p:WeaponPartChild, params:WeaponGenParams):WeaponPart {
        var parts:List<WeaponPart> = Lambda.filter(PartRegistry.parts, function(part:WeaponPart):Bool { 
            if (!allowsCost(part, params)) return false;
            for (r in p.requirements) {
                if (!r(part)) return false;
            }
            return true;
        });
        if (parts == null || parts.length < 1) return null;
        return randomFromList(parts);
    }
    private static function generateOne(params:WeaponGenParams):WeaponData {
        // Get a base layer
        var baseParts:List<WeaponPart> = Lambda.filter(PartRegistry.parts, function(p:WeaponPart):Bool { 
            return allowsCost(p, params) && Lambda.exists(p.properties, function(wp:WeaponProperty):Bool { return wp.type == WeaponPropertyType.IS_BASE && wp.value; });
        });
        if (baseParts == null || baseParts.length < 1) return null;
        var basePart:WeaponPart = randomFromList(baseParts);
        subtractCost(basePart, params);
        var baseLayer:WeaponLayer = new WeaponLayer(basePart.name);


        // Begin adding parts
        var optionalParts:Array<Dynamic> = [];
        
        // Finalize required parts
        if (!finalizeRequirements(baseLayer, params)) return null;
        
        // Maybe add additional parts
        var passes:Int = 5;
        while (Math.random() > 0.5 && passes > 0) {
            passes--;
            if (getAllOptional(params, baseLayer, optionalParts)) {
                // Shuffle
                for (i in (0...optionalParts.length)) {
                    var ai:Int = Std.int(Math.random() * optionalParts.length);
                    var bi:Int = Std.int(Math.random() * optionalParts.length);
                    var buf = optionalParts[ai];
                    optionalParts[ai] = optionalParts[bi];
                    optionalParts[bi] = buf;
                }
                
                // Add a random amount of parts
                var randomCount:Int = Std.int(Math.random() * (optionalParts.length + 1));
                for (i in 0...randomCount) {
                    var parent:WeaponLayer = optionalParts[i].parent;
                    var child:WeaponPartChild = optionalParts[i].child;
                    
                    var newPart:WeaponPart = satisfyingPart(child, params);
                    if (newPart == null) continue;
                    
                    // Make sure this layer is finalized before it can be added
                    var newLayer:WeaponLayer = new WeaponLayer(newPart.name);
                    if (finalizeRequirements(newLayer, params)) {
                        subtractCost(newPart, params);
                        parent.children.push(new Pair(optionalParts[i].offset, newLayer));
                    }
                }
            }
        }
        
        var data:WeaponData = WeaponGenerator.buildFromParts(baseLayer);
        return data;
    }
    private static function finalizeRequirements(baseLayer:WeaponLayer, params:WeaponGenParams):Bool {
        var oe:Int = params.evolutionPoints;
        var os:Int = params.shadynessPoints;
        var oh:Int = params.historicalPoints;
        
        var requiredParts:Array<Dynamic> = [];
        while (getAllRequired(params, baseLayer, requiredParts)) {
            for (requirement in requiredParts) {
                var parent:WeaponLayer = requirement.parent;
                var child:WeaponPartChild = requirement.child;
                
                var newPart:WeaponPart = satisfyingPart(child, params);
                if (newPart == null) {
                    // We've run out of points, reset data
                    params.evolutionPoints = oe;
                    params.shadynessPoints = os;
                    params.historicalPoints = oh;
                    return false;
                }
                
                subtractCost(newPart, params);
                parent.children.push(new Pair(requirement.offset, new WeaponLayer(newPart.name)));
            }
            
            requiredParts = [];
        }
        
        return true;
    }
    private static function getAllRequired(params:WeaponGenParams, l:WeaponLayer, listRequired:Array<Dynamic>):Bool {
        traverse(l, function(wl:WeaponLayer):Void {
            var i:Int = 0;
            for (wc in wl.part.children) {
                if (!Lambda.exists(wl.children, function(p):Bool { return p.first == i; } )) {
                    if (wc.isRequired) {
                        listRequired.push( {
                            parent:wl,
                            child:wc,
                            offset:i
                        });
                    }
                }
                i++;
            }
        });
        return listRequired.length > 0;
    }
    private static function getAllOptional(params:WeaponGenParams, l:WeaponLayer, listOptional:Array<Dynamic>):Bool {
        traverse(l, function(wl:WeaponLayer):Void {
            var i:Int = 0;
            for (wc in wl.part.children) {
                if (!Lambda.exists(wl.children, function(p):Bool { return p.first == i; } )) {
                    if (!wc.isRequired) {
                        listOptional.push( {
                            parent:wl,
                            child:wc,
                            offset:i
                        });
                    }
                }
                i++;
            }
        });
        return listOptional.length > 0;
    }
    private static function traverse(l:WeaponLayer, f:WeaponLayer->Void) {
        f(l);
        for (c in l.children) traverse(c.second, f);
    }
    public static function generate(params:WeaponGenParams):WeaponData {
        var tries:Int = 20;
        var weapons:Array<WeaponData> = [];
        while (tries > 0) {
            var pCopy:WeaponGenParams = new WeaponGenParams();
            pCopy.evolutionPoints = params.evolutionPoints;
            pCopy.shadynessPoints = params.shadynessPoints;
            pCopy.historicalPoints = params.historicalPoints;
            var newWeapon:WeaponData = generateOne(pCopy);
            if (newWeapon != null) weapons.push(newWeapon);
            tries--;
        }
        if (weapons.length < 1) return null;
        
        return randomFromArray(weapons);
    }

    public static function generateInitialWeapons():Array<WeaponData> {
        var weapons:Array<WeaponData> = [];

        // Temp variables
        var w:WeaponData = null;
        var l:WeaponLayer = null;

        // Rifle
        l = new WeaponLayer("Receiver.Conventional", [
            new Pair(0, new WeaponLayer("Barrel.Conventional", [
                new Pair(0, new WeaponLayer("Magazine.Conventional")),
                new Pair(1, new WeaponLayer("Stock.Conventional")),
                new Pair(2, new WeaponLayer("Projectile.Bullet"))
            ])),
            new Pair(1, new WeaponLayer("Grip.Conventional"))
        ]);
        w = buildFromParts(l);
        w.name = "M34 Sport Rifle";
        w.colorScheme = new ColorScheme(0xffff0000, 0xff00ff00, 0xff0000ff, 0, 0, 1, 1);
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
        weapons.push(w);

        // Grenade launcher
        l = new WeaponLayer("Receiver.Conventional", [
            new Pair(0, new WeaponLayer("Barrel.Launcher", [
                new Pair(0, new WeaponLayer("Magazine.Conventional")),
                new Pair(1, new WeaponLayer("Stock.Conventional")),
                new Pair(2, new WeaponLayer("Projectile.Grenade"))
            ])),
            new Pair(1, new WeaponLayer("Grip.Conventional"))
        ]);
        w = buildFromParts(l);
        w.name = "Junk'n'Chuck";
        w.colorScheme = new ColorScheme(0xffff0000, 0xff00ff00, 0xff0000ff, 0, 0, 1, 1);
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
        weapons.push(w);

        // Flare gun
        l = new WeaponLayer("Receiver.Conventional", [
            new Pair(0, new WeaponLayer("Barrel.Launcher", [
                new Pair(0, new WeaponLayer("Magazine.Conventional")),
                new Pair(1, new WeaponLayer("Stock.Conventional")),
                new Pair(2, new WeaponLayer("Projectile.Flare"))
            ])),
            new Pair(1, new WeaponLayer("Grip.Conventional"))
        ]);
        w = buildFromParts(l);
        w.name = "Rescue Flare Gun";
        w.colorScheme = new ColorScheme(0xffff0000, 0xff00ff00, 0xff0000ff, 0, 0, 1, 1);
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
        w.projectileOrigins[0].velocity = 10;
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