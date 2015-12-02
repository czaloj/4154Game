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
                return Lambda.find(classes, p.value) != null;
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
    
    public static var parts:StringMap<WeaponPart> = {
        var list:Array<WeaponPart> = [
            new WeaponPart(
                "Receiver.Conventional",
                WeaponPartType.RECEIVER,
                5, 5,
                19, 7,
                6, 4,
                [
                    new WeaponPartChild(new Matrix(1, 0, 0, 1, 0, 0), true, [requirementPart(WeaponPartType.BARREL)]),
                    new WeaponPartChild(new Matrix(1, 0, 0, 1, 3, 4), true, [requirementPart(WeaponPartType.GRIP)]),
                    new ColorScheme(0xffff0000, 0xff00ff00, 0xff0000ff, 0, 0, 1, 1)
                ]),
                
            new WeaponPart(
                "Barrel.Conventional",
                WeaponPartType.BARREL,
                1, 19,
                58, 17,
                0, 8,
                [
                    new WeaponPartChild(new Matrix(1, 0, 0, 1, 17, 15), true, [requirementPart(WeaponPartType.MAGAZINE)]),
                    new WeaponPartChild(new Matrix(1, 0, 0, 1, 0, 4), false, [requirementPart(WeaponPartType.STOCK)]),
                    new WeaponPartChild(new Matrix(1, 0, 0, 1, 0, 0), false, [requirementPart(WeaponPartType.PROJECTILE)]),
                    new WeaponProperty(WeaponPropertyType.EXIT_INFORMATION, new ProjectileExitData(58, 5.5, 1, 0, 0.3, 1500)),
                    new WeaponProperty(WeaponPropertyType.USES_PER_ACTIVATION, 1),
                    new WeaponProperty(WeaponPropertyType.ACTIVATION_COOLDOWN, 0.15),
                    new WeaponProperty(WeaponPropertyType.FIRING_MODE, FiringMode.AUTOMATIC)
                ]),
                
            new WeaponPart(
                "Barrel.Launcher",
                WeaponPartType.BARREL,
                1, 19,
                58, 17,
                0, 8,
                [
                    new WeaponPartChild(new Matrix(1, 0, 0, 1, 17, 15), true, [requirementPart(WeaponPartType.MAGAZINE)]),
                    new WeaponPartChild(new Matrix(1, 0, 0, 1, 0, 4), false, [requirementPart(WeaponPartType.STOCK)]),
                    new WeaponPartChild(new Matrix(1, 0, 0, 1, 0, 0), false, [requirementPart(WeaponPartType.PROJECTILE)]),
                    new WeaponProperty(WeaponPropertyType.EXIT_INFORMATION, new ProjectileExitData(58, 5.5, 1, 0, 0.6, 30)),
                    new WeaponProperty(WeaponPropertyType.USES_PER_ACTIVATION, 1),
                    new WeaponProperty(WeaponPropertyType.ACTIVATION_COOLDOWN, 0.5),
                    new WeaponProperty(WeaponPropertyType.FIRING_MODE, FiringMode.SINGLE)
                ]),
                
            new WeaponPart(
                "Grip.Conventional",
                WeaponPartType.GRIP,
                12, 82,
                7, 10,
                7, 0,
                [
                    
                ]),
                
            new WeaponPart(
                "Stock.Conventional",
                WeaponPartType.STOCK,
                6, 66,
                22, 11,
                22, 0,
                [
                
                ]),
                
            new WeaponPart(
                "Magazine.Conventional",
                WeaponPartType.MAGAZINE,
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
                    }) 
                ]),
            
            new WeaponPart(
                "Projectile.Grenade",
                WeaponPartType.PROJECTILE,
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
                    }) 
                ]),
                
            new WeaponPart(
                "Projectile.Flare",
                WeaponPartType.PROJECTILE,
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
                    })
                ]),
                
            new WeaponPart(
                "Projectile.Melee",
                WeaponPartType.PROJECTILE,
                1017, 5,
                7, 7,
                4, 4,
                [
                    new WeaponProperty(WeaponPropertyType.PROJECTILE_DATA, { 
                        var pd:ProjectileData = new ProjectileData(ProjectileData.TYPE_MELEE);
                        pd.damage = 10;
                        pd.damageFriendly = 0;
                        pd;
                    }) 
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