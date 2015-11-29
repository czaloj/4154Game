package weapon;

import game.ColorScheme;
import haxe.ds.StringMap;
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
                    new WeaponPartChild(0, 0, true, [requirementPart(WeaponPartType.BARREL)]),
                    new WeaponPartChild(3, 4, true, [requirementPart(WeaponPartType.GRIP)]),
                    new ColorScheme(0xffff0000, 0xff00ff00, 0xff0000ff, 0, 0, 1, 1)
                ]),
                
            new WeaponPart(
                "Barrel.Conventional",
                WeaponPartType.BARREL,
                1, 19,
                58, 17,
                0, 8,
                [
                    new WeaponPartChild(16, 17, true, [requirementPart(WeaponPartType.MAGAZINE)]),
                    new WeaponPartChild(0, 4, false, [requirementPart(WeaponPartType.STOCK)]),
                    new WeaponProperty(WeaponPropertyType.PROJECTILE_ORIGIN, new ProjectileData(ProjectileData.TYPE_BULLET)),
                    new WeaponProperty(WeaponPropertyType.EXIT_INFORMATION, new ProjectileExitData(58, 5.5, 1, 0, 0.3, 1500)),
                    new WeaponProperty(WeaponPropertyType.USES_PER_ACTIVATION, 1),
                    new WeaponProperty(WeaponPropertyType.ACTIVATION_COOLDOWN, 0.15),
                    new WeaponProperty(WeaponPropertyType.FIRING_MODE, FiringMode.AUTOMATIC)
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