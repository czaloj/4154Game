package graphics;

import starling.display.Image;
import starling.textures.Texture;

class ParallaxSprite extends Image {
    private var ratioX:Float;
    private var sizeX:Float;
    private var ratioY:Float;
    private var sizeY:Float;
    
    public function new(t:Texture, mapWidth:Float, mapHeight:Float, screenWidth:Float, screenHeight:Float) {
        super(t);
        
        sizeX = t.width - screenWidth;
        sizeY = t.height - screenHeight;
        ratioX = t.width / mapWidth;
        ratioY = t.height / mapHeight;
    }
    
    public function update(rx:Float, ry:Float):Void {
        x = -rx * sizeX;
        y = -ry * sizeY;
    }
}
