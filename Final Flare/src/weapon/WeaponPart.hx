package weapon;

import game.ColorScheme;
import openfl.Assets;
import openfl.Lib;
import starling.display.Sprite;
import starling.events.Event;
import starling.utils.AssetManager;
import starling.core.Starling;
import starling.display.Image;
import starling.textures.Texture;
import flash.display.BitmapData;

class WeaponPart {
    public var names(default, null):Array<PartName>;
    public var schemes(default, null):Array<ColorScheme>;
    public var properties(default, null):Array<WeaponProperty>;
    
    public function new(var def:Array<Dynamic>) {
        names = [];
        schemes = [];
        properties = [];
        
        for(i in def) {
            switch Type.getClass(i) {
            case PartName:
                names.push(i);
            case Array<PartName>:
                names.concat(i);
            case ColorScheme:
                schemes.push(i);
            case Array<ColorScheme>:
                schemes.concat(i);
            case WeaponProperty:
                properties.push(i);
            case Array<WeaponProperty>:
                properties.concat(i);
            default:
                trace("Unknown argument");
            }
        }
    }
}
