package weapon;

import game.ColorScheme;
import haxe.ds.StringMap;
import openfl.geom.Matrix;
import weapon.projectile.Projectile;
import weapon.projectile.ProjectileData;
import weapon.WeaponPart.ProjectileExitData;
import weapon.WeaponData.FiringMode;

class PartRegistry {
    public static function requirementPart(t:WeaponPartType):WeaponPart->Bool {
        return function(p:WeaponPart):Bool {
            return p.type == t;
        }
    }
    public static function requirementSubclass(classes:Array<String>, blackList:Bool = false):WeaponPart->Bool {
        return function(p:WeaponPart):Bool {
            var c:Int = Lambda.count(p.properties, function(p:WeaponProperty):Bool {
                if (p.type != WeaponPropertyType.SUB_CLASS) return false;
                return Lambda.exists(classes, function(sc:String):Bool { return sc == p.value; });
            });
            return c == (blackList ? 0 : classes.length);
        }
    }
    public static function requirementLooseSubclass(classes:Array<String>, blackList:Bool = false):WeaponPart->Bool {
        return function(p:WeaponPart):Bool {
            var c:Int = Lambda.count(p.properties, function(p:WeaponProperty):Bool {
                if (p.type != WeaponPropertyType.SUB_CLASS) return false;
                return Lambda.find(classes, p.value) != null;
            });
            return blackList ? (c < classes.length) : (c > 0);
        }
    }
    
    private static var SCHEMES_GENERIC:Array<ColorScheme> = [
        new ColorScheme(0xffb3b3b3, 0xff663300, 0xff1aff1a, 0, 0, 1, 1),
        new ColorScheme(0xffdddddd, 0xff0043e0, 0xff001284, 0, 0, 1, 1),
        new ColorScheme(0xff101010, 0xff303030, 0xff500000, 0, 0, 1, 1)
    ];
    
    private static function rotated(m:Matrix, a:Float):Matrix {
        var mr:Matrix = new Matrix();
        mr.rotate(-a);
        mr.concat(m);
        return mr;
    }
    
    public static var parts:StringMap<WeaponPart> = {
        var list:Array<WeaponPart> = [
            new WeaponPart(
                "Receiver.Conventional",
                WeaponPartType.RECEIVER,
                15, 0, 0,
                5, 5,
                19, 7,
                6, 4,
                [
                    new WeaponPartChild(new Matrix(1, 0, 0, 1, 0, 0), true, [requirementPart(WeaponPartType.BARREL), requirementSubclass(["Generic"])]),
                    new WeaponPartChild(new Matrix(1, 0, 0, 1, 3, 4), true, [requirementPart(WeaponPartType.GRIP)]),
                    new WeaponProperty(WeaponPropertyType.IS_BASE, true),
                    new WeaponProperty(WeaponPropertyType.SUB_CLASS, "Conventional"),
                    SCHEMES_GENERIC
                ]),
                
            new WeaponPart(
                "Barrel.Conventional",
                WeaponPartType.BARREL,
                50, 0, 0,
                1, 19,
                58, 17,
                0, 8,
                [
                    new WeaponPartChild(new Matrix(1, 0, 0, 1, 17, 15), true, [requirementPart(WeaponPartType.MAGAZINE)]),
                    new WeaponPartChild(new Matrix(1, 0, 0, 1, 0, 4), false, [requirementPart(WeaponPartType.STOCK)]),
                    new WeaponPartChild(new Matrix(1, 0, 0, 1, 0, 0), true, [requirementPart(WeaponPartType.PROJECTILE), requirementSubclass(["Bullet"])]),
                    new WeaponProperty(WeaponPropertyType.EXIT_INFORMATION, new ProjectileExitData(58, 5.5, 1, 0, 0.3, 1500)),
                    new WeaponProperty(WeaponPropertyType.USES_PER_ACTIVATION, 1),
                    new WeaponProperty(WeaponPropertyType.ACTIVATION_COOLDOWN, 0.15),
                    new WeaponProperty(WeaponPropertyType.SUB_CLASS, "Generic"),
                    new WeaponProperty(WeaponPropertyType.FIRING_MODE, FiringMode.AUTOMATIC)
                ]),
                
            new WeaponPart(
                "Barrel.HighVelocity",
                WeaponPartType.BARREL,
                250, 0, 0,
                1, 95,
                64, 15,
                0, 8,
                [
                    new WeaponPartChild(rotated(new Matrix(1, 0, 0, 1, 19, 14), Math.PI * 0.25), true, [requirementPart(WeaponPartType.MAGAZINE)]),
                    new WeaponPartChild(new Matrix(1, 0, 0, 1, 0, 4), false, [requirementPart(WeaponPartType.STOCK)]),
                    new WeaponPartChild(new Matrix(1, 0, 0, 1, 0, 0), true, [requirementPart(WeaponPartType.PROJECTILE), requirementSubclass(["Bullet"])]),
                    new WeaponProperty(WeaponPropertyType.EXIT_INFORMATION, new ProjectileExitData(62, 5.5, 1, 0, 0.3, 2400)),
                    new WeaponProperty(WeaponPropertyType.USES_PER_ACTIVATION, 1),
                    new WeaponProperty(WeaponPropertyType.ACTIVATION_COOLDOWN, 0.35),
                    new WeaponProperty(WeaponPropertyType.SUB_CLASS, "Generic"),
                    new WeaponProperty(WeaponPropertyType.FIRING_MODE, FiringMode.BURST),
                    new WeaponProperty(WeaponPropertyType.BURST_COUNT, 3),
                    new WeaponProperty(WeaponPropertyType.BURST_PAUSE, 0.05),
                    new WeaponProperty(WeaponPropertyType.DAMAGE_INCREASE, 5)
                ]),
                
            new WeaponPart(
                "Barrel.Launcher",
                WeaponPartType.BARREL,
                120, 0, 0,
                1, 19,
                58, 17,
                0, 8,
                [
                    new WeaponPartChild(new Matrix(1, 0, 0, 1, 17, 15), true, [requirementPart(WeaponPartType.MAGAZINE)]),
                    new WeaponPartChild(new Matrix(1, 0, 0, 1, 0, 4), false, [requirementPart(WeaponPartType.STOCK)]),
                    new WeaponPartChild(new Matrix(1, 0, 0, 1, 0, 0), false, [requirementPart(WeaponPartType.PROJECTILE), requirementSubclass(["LargeProjectile"])]),
                    new WeaponProperty(WeaponPropertyType.EXIT_INFORMATION, new ProjectileExitData(58, 5.5, 1, 0, 0.6, 30)),
                    new WeaponProperty(WeaponPropertyType.USES_PER_ACTIVATION, 1),
                    new WeaponProperty(WeaponPropertyType.ACTIVATION_COOLDOWN, 0.5),
                    new WeaponProperty(WeaponPropertyType.SUB_CLASS, "Generic"),
                    new WeaponProperty(WeaponPropertyType.FIRING_MODE, FiringMode.SINGLE)
                ]),
                
            new WeaponPart(
                "Grip.Conventional",
                WeaponPartType.GRIP,
                5, 0, 0,
                12, 82,
                7, 10,
                7, 0,
                [
                    
                ]),
                
            new WeaponPart(
                "Stock.Conventional",
                WeaponPartType.STOCK,
                12, 0, 0,
                6, 66,
                22, 11,
                22, 0,
                [
                    new WeaponProperty(WeaponPropertyType.ACCURACY_MODIFIER, 0.7)
                ]),
                
            new WeaponPart(
                "Magazine.Conventional",
                WeaponPartType.MAGAZINE,
                25, 0, 0,
                18, 46,
                10, 13,
                0, 0,
                [
                    new WeaponProperty(WeaponPropertyType.RELOAD_TIME, 2.4),
                    new WeaponProperty(WeaponPropertyType.USE_CAPACITY, 36),
                ]),
                
            new WeaponPart(
                "Projectile.Bullet",
                WeaponPartType.PROJECTILE,
                30, 0, 0,
                1017, 0,
                7, 4,
                3, 2,
                [
                    new WeaponProperty(WeaponPropertyType.PROJECTILE_DATA, { 
                        var pd:ProjectileData = new ProjectileData(ProjectileData.TYPE_BULLET);
                        pd.damage = 10;
                        pd.damageFriendly = 0;
                        pd.penetrationCount = 0;
                        pd.gravityAcceleration = 0.0;
                        pd;
                    }),
                    new WeaponProperty(WeaponPropertyType.SUB_CLASS, "Bullet")
                ]),
            
            new WeaponPart(
                "Projectile.Grenade",
                WeaponPartType.PROJECTILE,
                60, 0, 0,
                1017, 5,
                7, 7,
                4, 4,
                [
                    new WeaponProperty(WeaponPropertyType.PROJECTILE_DATA, { 
                        var pd:ProjectileData = new ProjectileData(ProjectileData.TYPE_LARGE);
                        pd.damage = 40;
                        pd.damageFriendly = 20;
                        pd.timer = 0.5;
                        pd.explosiveRadius = 2.0;
                        pd.radius = 0.2;
                        pd;
                    }),
                    new WeaponProperty(WeaponPropertyType.SUB_CLASS, "LargeProjectile")
                ]),
                
            new WeaponPart(
                "Projectile.Flare",
                WeaponPartType.PROJECTILE,
                15, 0, 0,
                1017, 13,
                7, 13,
                4, 7,
                [
                    new WeaponProperty(WeaponPropertyType.PROJECTILE_DATA, { 
                        var pd:ProjectileData = new ProjectileData(ProjectileData.TYPE_FLARE);
                        pd.damage = 0;
                        pd.damageFriendly = 0;
                        pd.timer = 3.0;
                        pd.explosiveRadius = 1.0;
                        pd.radius = 0.05;
                        pd;
                    }),
                    new WeaponProperty(WeaponPropertyType.SUB_CLASS, "Flare")
                ]),
                
            new WeaponPart(
                "Projectile.Melee",
                WeaponPartType.PROJECTILE,
                80, 0, 0,
                1017, 5,
                7, 7,
                4, 4,
                [
                    new WeaponProperty(WeaponPropertyType.PROJECTILE_DATA, { 
                        var pd:ProjectileData = new ProjectileData(ProjectileData.TYPE_MELEE);
                        pd.damage = 10;
                        pd.damageFriendly = 0;
                        pd;
                    }),
                    new WeaponProperty(WeaponPropertyType.SUB_CLASS, "Melee")
                ]),
        ];
        
        var m:StringMap<WeaponPart> = new StringMap<WeaponPart>();
        for (p in list) m.set(p.name, p);
        m;
    };
    
    public function new() {
        // Empty
    }
}