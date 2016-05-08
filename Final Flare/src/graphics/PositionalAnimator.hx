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
    public var chain:Array<PAFrame> = [];
    private var time:Float = 0;
    
    public function new(looping:Bool = true) {
        isLooped = looping;
    }
    
    public function addFrame(x:Float, y:Float, r:Float):Void {
        if (chain.length > 0) totalTime += chain[chain.length - 1].time;
        chain.push(new PAFrame(x, y, r));
    }
    public function readdFrame(i:Int):Void {
        totalTime += chain[chain.length - 1].time;
        chain.push(chain[i]);
    }
    
    /**
     * 
     * @param dt Time increment
     * @return True if the animation has ended or looped over
     */
    public function update(dt:Float, sprite:DisplayObject):Bool {
        // Reached end of non-looping animation
        if (index < 0 || index >= (chain.length - 1)) return true;
        
        // Update time variable
        timeInAnimation += dt;
        time -= dt;
        var done:Bool = false;
        while (time < 0) {
            index++;
            if (index == (chain.length - 1)) {
                done = true;
                if (isLooped) {
                    timeInAnimation -= totalTime;
                    index = 0;
                }
                else {
                    timeInAnimation = totalTime;
                    break;
                }
            }
            if (index < (chain.length - 1)) {
                time += chain[index].time;
            }
        }
        
        if (index < (chain.length - 1)) {
            // Lerp animation data
            var r:Float = time / chain[index].time;
            sprite.x = r * chain[index].xOff + (1 - r) * chain[index + 1].xOff;
            sprite.y = r * chain[index].yOff + (1 - r) * chain[index + 1].yOff;
            sprite.rotation = r * chain[index].rotation + (1 - r) * chain[index + 1].rotation;
        }
        else {
            // At the end of a non-looped animation
            sprite.x = chain[chain.length - 1].xOff;
            sprite.y = chain[chain.length - 1].yOff;
            sprite.rotation = chain[chain.length - 1].rotation;
        }
        return done;
    }
    
    // Resets the animation at a certain point
    public function resetTime(t:Float):Void {
        timeInAnimation = t;
        if (timeInAnimation > totalTime) {
            if (!isLooped) {
                timeInAnimation = totalTime;
                index = chain.length - 1;
                return;                
            }
            else {
                timeInAnimation = timeInAnimation % totalTime;
            }
        }
        time = timeInAnimation;

        index = 0;
        while (index < chain.length - 1 && time > chain[index].time) {
            time -= chain[index++].time;
        }
        time = chain[index].time - time;
    }
    
    public function scaleToTime(t:Float):Void {
        for (frame in 0...(chain.length - 1)) chain[frame].time *= t / totalTime;
        time *= t / totalTime;
        timeInAnimation *= t / totalTime;
        
        totalTime = t;
    }
}