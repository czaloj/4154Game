package;

import starling.events.Event;
import starling.display.Image;
import starling.textures.Texture;

class Animated extends Image {
    private var ss:SpriteSheet;
    private var strip:SpriteStrip;
    private var f:Int = 0;
    private var fDelay:Int = 1;
    private var delay:Int = 0;
    
    public function new(s:SpriteSheet, strip:String, delay:Int = 1) {
        super(s.texture);
        ss = s;
        this.strip = ss.getStrip(strip);
        width = this.strip.width;
        height = this.strip.height;
        this.delay = delay;
        addEventListener(Event.ENTER_FRAME, update);
    }
    
    private function update(e:Event = null):Void {
        fDelay--;
        if (fDelay <= 0) {
            fDelay = delay;
            f++;
            f %= strip.totalFrames;
            strip.setToFrame(this, f);
        }
    }
}