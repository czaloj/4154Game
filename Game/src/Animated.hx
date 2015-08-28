package;

import starling.events.Event;
import starling.display.Image;
import starling.textures.Texture;

class Animated extends Image {
    private var ss:SpriteSheet;
    private var strip:SpriteStrip;
    private var f:Int = 0;
    
    public function new(s:SpriteSheet, strip:String) {
        super(s.texture);
        ss = s;
        this.strip = ss.getStrip(strip);
        width = this.strip.width;
        height = this.strip.height;
        addEventListener(Event.ENTER_FRAME, update);
    }
    
    private function update(e:Event = null):Void {
        f++;
        f %= 10;
        strip.setToFrame(this, f);
    }
}