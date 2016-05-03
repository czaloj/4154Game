package weapon;

import game.ColorScheme;
import haxe.ds.StringMap;
import openfl.geom.Matrix;
import weapon.projectile.Projectile;
import weapon.projectile.ProjectileData;
import weapon.WeaponPart.DamagePolygonData;
import weapon.WeaponPart.ProjectileExitData;
import weapon.WeaponData.FiringMode;

class PartRegistry {
    public static function requirementPart(t:WeaponPartType):WeaponPart->Bool {
        return function(p:WeaponPart):Bool {
            return p.type == t;
        }
    }
    public static function requirementReqChildrenLessThanOrEqual(v:Int):WeaponPart->Bool {
        return function(p:WeaponPart):Bool {
            var pCC = Lambda.find(p.properties, function(sc:WeaponProperty):Bool { return sc.type == WeaponPropertyType.CHILDREN_REQUIRED; });
            return pCC.value <= v;
        }
    }
    public static function requirementTotalChildrenLessThanOrEqual(v:Int):WeaponPart->Bool {
        return function(p:WeaponPart):Bool {
            var pCC = Lambda.find(p.properties, function(sc:WeaponProperty):Bool { return sc.type == WeaponPropertyType.TOTAL_CHILDREN; });
            return pCC.value <= v;
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
        new ColorScheme(0xff101010, 0xff303030, 0xff500000, 0, 0, 1, 1),
        new ColorScheme(0xff830404, 0xff220000, 0xff6d5d5d, 0, 0, 1, 1),
        new ColorScheme(0xffd196ef, 0xffd2cbd5, 0xff241a29, 0, 0, 1, 1),
        new ColorScheme(0xff7b9f99, 0xff1a4566, 0xff08f996, 0, 0, 1, 1),
        new ColorScheme(0xff202020, 0xffd1e304, 0xff46020a, 0, 0, 1, 1),
        new ColorScheme(0xff494949, 0xffb962cf, 0xffffa1ee, 0, 0, 1, 1),
        new ColorScheme(0xffa0631c, 0xff887122, 0xff666666, 0, 0, 1, 1),
        new ColorScheme(0xffc9b338, 0xffac9124, 0xffd09e17, 0, 0, 1, 1),
    ];
    private static var SCHEMES_METALLIC:Array<ColorScheme> = [
        new ColorScheme(0xffc3c3c3, 0xffaaaaaa, 0xff404040, 0, 0, 1, 1),
        new ColorScheme(0xff874200, 0xff032150, 0xff888888, 0, 0, 1, 1),
        new ColorScheme(0xffe01010, 0xff201010, 0xffbbcc00, 0, 0, 1, 1),
        new ColorScheme(0xffc9b338, 0xffac9124, 0xffd09e17, 0, 0, 1, 1),
        new ColorScheme(0xff202020, 0xffd1e304, 0xff46020a, 0, 0, 1, 1),
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
                    new WeaponProperty(WeaponPropertyType.IS_BASE, 6),
                    new WeaponProperty(WeaponPropertyType.SUB_CLASS, "Conventional"),
                    SCHEMES_GENERIC
                ]),
            
            new WeaponPart(
                "Handle.Simple",
                WeaponPartType.RECEIVER,
                5, 0, 0,
                35, 2,
                4, 11,
                2, 6,
                [
                    new WeaponPartChild(new Matrix(1, 0, 0, 1, 2, 0), true, [requirementPart(WeaponPartType.BARREL), requirementSubclass(["Melee"])]),
                    new WeaponProperty(WeaponPropertyType.IS_BASE, 1),
                    new WeaponProperty(WeaponPropertyType.SUB_CLASS, "Melee"),
                    SCHEMES_METALLIC
                ]),
                
            new WeaponPart(
                "Handle.Ergonomic",
                WeaponPartType.RECEIVER,
                45, 0, 0,
                44, 2,
                8, 15,
                4, 8,
                [
                    new WeaponPartChild(new Matrix(1, 0, 0, 1, 4, 0), true, [requirementPart(WeaponPartType.BARREL), requirementSubclass(["Melee"])]),
                    new WeaponProperty(WeaponPropertyType.IS_BASE, 1),
                    new WeaponProperty(WeaponPropertyType.SUB_CLASS, "Melee"),
                    new WeaponProperty(WeaponPropertyType.DAMAGE_INCREASE, 7),
                    SCHEMES_METALLIC
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
                "Barrel.Pistol",
                WeaponPartType.BARREL,
                150, 0, 0,
                46, 41,
                36, 9,
                2, 7,
                [
                    new WeaponPartChild(new Matrix(1, 0, 0, 1, 0, 4), false, [requirementPart(WeaponPartType.STOCK)]),
                    new WeaponPartChild(new Matrix(1, 0, 0, 1, 0, 0), true, [requirementPart(WeaponPartType.PROJECTILE), requirementSubclass(["Bullet"])]),
                    new WeaponProperty(WeaponPropertyType.EXIT_INFORMATION, new ProjectileExitData(36, 1.5, 1, 0, 0.6, 1200)),
                    new WeaponProperty(WeaponPropertyType.USES_PER_ACTIVATION, 1),
                    new WeaponProperty(WeaponPropertyType.ACTIVATION_COOLDOWN, 0.015),
                    new WeaponProperty(WeaponPropertyType.SUB_CLASS, "Generic"),
                    new WeaponProperty(WeaponPropertyType.FIRING_MODE, FiringMode.SINGLE),
                    new WeaponProperty(WeaponPropertyType.RELOAD_TIME, 1.2),
                    new WeaponProperty(WeaponPropertyType.USE_CAPACITY, 6),
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
                    new WeaponProperty(WeaponPropertyType.ACTIVATION_COOLDOWN, 0.85),
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
                38, 61,
                47, 14,
                13, 8,
                [
                    new WeaponPartChild(new Matrix(1, 0, 0, 1, 17, 15), true, [requirementPart(WeaponPartType.MAGAZINE)]),
                    new WeaponPartChild(new Matrix(1, 0, 0, 1, 0, 0), true, [requirementPart(WeaponPartType.PROJECTILE), requirementSubclass(["LargeProjectile"])]),
                    new WeaponProperty(WeaponPropertyType.EXIT_INFORMATION, new ProjectileExitData(41, 7, 1, 0, 0.6, 30)),
                    new WeaponProperty(WeaponPropertyType.USES_PER_ACTIVATION, 1),
                    new WeaponProperty(WeaponPropertyType.ACTIVATION_COOLDOWN, 0.5),
                    new WeaponProperty(WeaponPropertyType.SUB_CLASS, "Generic"),
                    new WeaponProperty(WeaponPropertyType.FIRING_MODE, FiringMode.SINGLE)
                ]),
                
            new WeaponPart(
                "Barrel.DildoRocket",
                WeaponPartType.BARREL,
                400, 0, 0,
                84, 75,
                72, 20,
                21, 15,
                [
                    new WeaponPartChild(new Matrix(1, 0, 0, 1, 37, 19), false, [requirementPart(WeaponPartType.MAGAZINE)]),
                    new WeaponPartChild(new Matrix(1, 0, 0, 1, 0, 0), true, [requirementPart(WeaponPartType.PROJECTILE), requirementSubclass(["LargeProjectile"])]),
                    new WeaponProperty(WeaponPropertyType.EXIT_INFORMATION, new ProjectileExitData(49, 11, 1, 0, 0.8, 50)),
                    new WeaponProperty(WeaponPropertyType.USES_PER_ACTIVATION, 1),
                    new WeaponProperty(WeaponPropertyType.ACTIVATION_COOLDOWN, 0.25),
                    new WeaponProperty(WeaponPropertyType.SUB_CLASS, "Generic"),
                    new WeaponProperty(WeaponPropertyType.FIRING_MODE, FiringMode.AUTOMATIC),
                    new WeaponProperty(WeaponPropertyType.USE_CAPACITY, 10),
                    new WeaponProperty(WeaponPropertyType.DAMAGE_INCREASE, 20)
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
                "Magazine.Extended",
                WeaponPartType.MAGAZINE,
                80, 0, 0,
                95, 40,
                12, 14,
                2, 0,
                [
                    new WeaponPartChild(new Matrix(1, 0, 0, 1, 2, 12), true, [requirementPart(WeaponPartType.MAGAZINE), requirementTotalChildrenLessThanOrEqual(0)]),
                    new WeaponProperty(WeaponPropertyType.USE_CAPACITY, 12),
                    new WeaponProperty(WeaponPropertyType.RELOAD_TIME, 0.2),
                ]),
                
            new WeaponPart(
                "Magazine.DoubleSplit",
                WeaponPartType.MAGAZINE,
                100, 0, 0,
                115, 40,
                21, 29,
                5, 0,
                [
                    new WeaponPartChild(rotated(new Matrix(1, 0, 0, 1, 15, 16), Math.PI  / 3), true, [requirementPart(WeaponPartType.MAGAZINE), requirementTotalChildrenLessThanOrEqual(1)]),
                    new WeaponPartChild(rotated(new Matrix(1, 0, 0, 1, 15, 28), Math.PI  / 3), true, [requirementPart(WeaponPartType.MAGAZINE), requirementTotalChildrenLessThanOrEqual(1)]),
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
                "Club.Ragged",
                WeaponPartType.BARREL,
                80, 0, 0,
                214, 1,
                8, 25,
                4, 25,
                [
                    new WeaponProperty(WeaponPropertyType.DAMAGE_POLYGON, new DamagePolygonData(4, 12, 0.4, 1.0, 10, 0.2)),
                    new WeaponProperty(WeaponPropertyType.USES_PER_ACTIVATION, 0),
                    new WeaponProperty(WeaponPropertyType.ACTIVATION_COOLDOWN, 0.5),
                    new WeaponProperty(WeaponPropertyType.FIRING_MODE, FiringMode.AUTOMATIC),
                    new WeaponProperty(WeaponPropertyType.SUB_CLASS, "Melee")
                ]),
                
            new WeaponPart(
                "Club.Nightstick",
                WeaponPartType.BARREL,
                200, 0, 0,
                225, 1,
                4, 28,
                2, 28,
                [
                    new WeaponProperty(WeaponPropertyType.DAMAGE_POLYGON, new DamagePolygonData(2, 12, 0.3, 1.2, 15, 0.1)),
                    new WeaponProperty(WeaponPropertyType.USES_PER_ACTIVATION, 0),
                    new WeaponProperty(WeaponPropertyType.ACTIVATION_COOLDOWN, 0.3),
                    new WeaponProperty(WeaponPropertyType.FIRING_MODE, FiringMode.AUTOMATIC),
                    new WeaponProperty(WeaponPropertyType.SUB_CLASS, "Melee")
                ]),
                
            new WeaponPart(
                "Sword.Excavator",
                WeaponPartType.BARREL,
                600, 0, 0,
                232, 1,
                28, 74,
                14, 68,
                [
                    new WeaponProperty(WeaponPropertyType.DAMAGE_POLYGON, new DamagePolygonData(2, 12, 1.0, 2.0, 40, 0.5)),
                    new WeaponProperty(WeaponPropertyType.USES_PER_ACTIVATION, 0),
                    new WeaponProperty(WeaponPropertyType.ACTIVATION_COOLDOWN, 0.7),
                    new WeaponProperty(WeaponPropertyType.FIRING_MODE, FiringMode.AUTOMATIC),
                    new WeaponProperty(WeaponPropertyType.SUB_CLASS, "Melee")
                ])
        ];
        
        var m:StringMap<WeaponPart> = new StringMap<WeaponPart>();
        for (p in list) m.set(p.name, p);
        m;
    };
    
    public function new() {
        // Empty
    }
}