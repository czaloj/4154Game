package graphics;
import starling.display.DisplayObject;
import starling.display.Sprite;

class PAFrame {
    // Offset values for weapons
    public var xOff:Float;
    public var yOff:Float;
    public var rotation:Float;
    
    public function new(x:Float, y:Float, r:Float) {
        xOff = x;
        yOff = y;
        rotation = r;
    }
}

class PositionalAnimator {
    public var chain:Array<PAFrame>;
    public var timeline:KeyframeTimeline;
    public var ktc:KeyframeTraverseContext;
    public var timeScaling:Float = 1.0;
    
    public function new(kt:KeyframeTimeline, frames:Array<PAFrame>, looping:Bool = true) {
        timeline = kt;
        ktc = new KeyframeTraverseContext(kt, looping);
        if(frames != null) chain = frames.copy();
    }
    
    /**
     * 
     * @param dt Time increment
     * @return True if the animation has ended or looped over
     */
    public function update(dt:Float, sprite:DisplayObject):Bool {
        // Keep track if we are moving towards a boundary
        var reachingBoundary:Bool = (dt < 0) ? (ktc.left == 0) : (ktc.right == (chain.length - 1));
        
        // Update the frame
        ktc.traverse(dt * timeScaling);

        // Lerp animation data
        var r:Float = ktc.ratio;
        sprite.x = r * chain[ktc.right].xOff + (1 - r) * chain[ktc.left].xOff;
        sprite.y = r * chain[ktc.right].yOff + (1 - r) * chain[ktc.left].yOff;
        sprite.rotation = r * chain[ktc.right].rotation + (1 - r) * chain[ktc.left].rotation;

        // Signal if we reach a special boundary condition
        if (reachingBoundary) {
            if (ktc.looping) {
                return (dt < 0) ? (ktc.right == (chain.length - 1)) : (ktc.left == 0);
            }
            else {
                return (dt < 0) ? (ktc.ratio == 0.0) : (ktc.ratio == 1.0);
            }
        }
        return false;
    }
    
    // Resets the animation at a certain point
    public function resetTime(t:Float):Void {
        ktc.setToTime(t);
    }
    
    public function scaleToTime(t:Float):Void {
        timeScaling = timeline.totalTime / t;
    }
}