package graphics;

import starling.textures.Texture;
import haxe.ds.StringMap;

class SpriteSheet {
    public var texture:Texture;

    private var tiles:StringMap<TileRegion> = new StringMap<TileRegion>();
    private var strips:StringMap<StripRegion> = new StringMap<StripRegion>();
    
    public function new(t:Texture, r:Array<Dynamic>) {
        texture = t;
        for (o in r) {
            switch Type.getClass(o) {
            case StripRegion:
                strips.set(o.name, o);
            case TileRegion:
                tiles.set(o.name, o);
            default:
                trace("Unknown argument");
            }
            o.computeTrueCoords(Std.int(texture.width), Std.int(texture.height));
        }
    }
    
    public function getTile(name:String):TileRegion {
        return tiles.get(name);
    }
    public function getStrip(name:String):StripRegion {
        return strips.get(name);
    }
}