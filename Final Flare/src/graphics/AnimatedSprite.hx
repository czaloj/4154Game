package graphics;

import starling.events.Event;
import starling.display.Image;
import starling.textures.Texture;

class AnimatedSprite extends Image {
    private var ss:SpriteSheet;
    private var strip:StripRegion;
    private var f:Int = 0;
    private var fDelay:Int = 1;
    private var delay:Int = 0;
    private var flippedTexture:Bool;
    public var loop:Bool = true;
    
    public function new(s:SpriteSheet, strip:String, delay:Int = 1, flipTexture:Bool = true) {
        super(s.texture);
        
        ss = s;
        this.strip = ss.getStrip(strip);
        width = this.strip.width;
        height = this.strip.height;
        this.delay = delay;
        flippedTexture = flipTexture;
        
        addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
        addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
    }
    
    public function disposeListeners():Void {
        removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
        removeEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
    }
    private function onAddedToStage(e:Event = null):Void {
        addEventListener(Event.ENTER_FRAME, update);        
    }
    private function onRemovedFromStage(e:Event = null):Void {
        removeEventListener(Event.ENTER_FRAME, update);
    }

    public function reset():Void {
        fDelay = delay;
        f = 0;
    }
    
    private function update(e:Event = null):Void {
        fDelay--;
        if (fDelay <= 0) {
            fDelay = delay;
            f++;
            f = switch([f >= strip.totalFrames, loop]) {
                case [true, true]: 0;
                case [true, false]: strip.totalFrames - 1;
                case [false, _]: f;
            };
            strip.setToFrame(this, f, flippedTexture);
        }
    }
}
