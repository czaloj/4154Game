package;

import starling.textures.Texture;
import haxe.ds.StringMap;

class SpriteSheet {
    public var texture:Texture;
    private var strips:StringMap<SpriteStrip> = new StringMap<SpriteStrip>();
    
    public function new(t:Texture, s:Array<SpriteStrip>) {
        texture = t;
        for (strip in s) {
            strip.computeTrueCoords(Std.int(texture.width), Std.int(texture.height));
            strips.set(strip.name, strip);
        }
    }
    
    public function getStrip(name:String):SpriteStrip {
        return strips.get(name);
    }
}