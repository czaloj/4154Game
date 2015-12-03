package weapon;

import game.ColorScheme;
import openfl.Assets;
import openfl.geom.Point;
import openfl.Lib;
import starling.display.Sprite;
import starling.events.Event;
import starling.utils.AssetManager;
import starling.core.Starling;
import starling.display.Image;
import starling.textures.Texture;
import flash.display.BitmapData;

class ProjectileExitData {
    public var angle:Float;
    public var velocity:Float;
    public var offX:Float;
    public var offY:Float;
    public var dirX:Float;
    public var dirY:Float;
    
    public function new(x:Float, y:Float, dx:Float, dy:Float, a:Float, v:Float) {
        offX = x;
        offY = y;
        
        dirX = dx;
        dirY = dy;
        var l:Float = Math.sqrt(dirX * dirX + dirY * dirY);
        dirX /= l;
        dirY /= l;
        
        angle = a;
        velocity = v;
    }
}
class DamagePolygonData {
    public var offX:Float;
    public var offY:Float;
    public var width:Float;
    public var height:Float;
    public var damage:Int;
    public var timeActive:Float;
    
    public function new(x:Float, y:Float, w:Float, h:Float, damage:Int, t:Float) {
        offX = x;
        offY = y;
        width = w;
        height = h;
        this.damage = damage;
        timeActive = t;
    }
}

// This is a container that determines the generation of a full weapon
class WeaponPart {
    // The name of the part
    public var name:String;
    public var type:WeaponPartType;

    // The cost of the part
    public var costEvolution:Int;
    public var costShadyness:Int;
    public var costHistorical:Int;
    
    // A list of possible names and color schemes
    public var names(default, null):Array<PartName>;
    public var schemes(default, null):Array<ColorScheme>;
    
    // Texture rectangle in pixels
    public var sx:Int;
    public var sy:Int;
    public var w:Int;
    public var h:Int;
    
    // Offset to use for parenting in pixels
    public var offX:Int;
    public var offY:Int;
    
    // Children that 
    public var children:Array<WeaponPartChild> = [];

    // Additional weapon properties
    public var properties(default, null):Array<WeaponProperty>;
    
    public function new(
        n:String,
        pt:WeaponPartType,
        ce:Int, cs:Int, ch:Int,
        sx:Int, sy:Int,
        w:Int, h:Int,
        offX:Int, offY:Int,
        def:Array<Dynamic>
        ) {
        name = n;
        type = pt;
        costEvolution = ce;
        costShadyness = cs;
        costHistorical = ch;
        
        // Texture properties
        this.sx = sx;
        this.sy = sy;
        this.w = w;
        this.h = h;
        this.offX = offX;
        this.offY = offY;
        
        // Additional values
        names = [];
        schemes = [];
        properties = [];
        properties.push(new WeaponProperty(WeaponPropertyType.PART_TYPE, pt));
        addToThis(def);
        properties.push(new WeaponProperty(WeaponPropertyType.TOTAL_CHILDREN, children.length));
        var requiredChildren:Int = 0;
        for (c in children) if (c.isRequired) requiredChildren++;
        properties.push(new WeaponProperty(WeaponPropertyType.CHILDREN_REQUIRED, requiredChildren));
        
    }
    
    private function addToThis(a:Array<Dynamic>) {
        for(i in a) {
            switch Type.getClass(i) {
            case PartName:
                names.push(i);
            case ColorScheme:
                schemes.push(i);
            case WeaponProperty:
                properties.push(i);
            case WeaponPartChild:
                children.push(i);
            case Array:
                addToThis(i);
            default:
                trace("Unknown argument");
            }
        }
    }
}
