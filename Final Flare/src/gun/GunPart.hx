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
    
    public function new(var def:Array<Dynamic>) {
        names = [];
        
        for(i in def) {
            switch Type.getClass(i) {
            case PartName:
                names.append(i);
            default:
                trace("Unknown argument");
            }
        }
    }
}
