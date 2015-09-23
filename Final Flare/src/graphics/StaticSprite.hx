package graphics;

import starling.display.Image;
import starling.textures.Texture;

class StaticSprite extends Image {
    public function new(s:SpriteSheet, tile:String) {
        super(s.texture);

        var t:TileRegion = s.getTile(tile);
        t.setToTile(this);
        width = t.width;
        height = t.height;
    }
}
