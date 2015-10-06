package gun;

import openfl.Assets;
import openfl.Lib;
import starling.display.Sprite;
import starling.events.Event;
import starling.utils.AssetManager;
import starling.core.Starling;
import starling.display.Image;
import starling.textures.Texture;
import flash.display.BitmapData;

class GunPart {
    public var names(default, null):Array<PartName>;
    public var schemes(default, null):Array<GunColorScheme>;
    public var properties(default, null):Array<GunProperty>;
    
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
            case GunColorScheme:
                schemes.push(i);
            case Array<GunColorScheme>:
                schemes.concat(i);
            case GunProperty:
                properties.push(i);
            case Array<GunProperty>:
                properties.concat(i);
            default:
                trace("Unknown argument");
            }
        }
    }
}
