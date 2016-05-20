package;

class KeyframeTraverseContext {
    public var timeline:KeyframeTimeline;
    public var looping:Bool;
    
    public var time:Float;
    public var index:Int;
    
    public var left(get, never):Int;
    public var right(get, never):Int;
    public var ratio(get, never):Float;
    
    public function get_left():Int {
        return index;
    }
    public function get_right():Int {
        return index + 1;
    }
    public function get_ratio():Float {
        return (time - timeline.accumulations[index]) / timeline.intervals[index];
    }
    
    public function new(kt:KeyframeTimeline, loop:Bool = false) {
        timeline = kt;
        looping = loop;
    }
    
    public function setToTime(t:Float):KeyframeTraverseContext {
        time = t;
        if (time < 0) {
            if (looping) {
                time = timeline.totalTime - (Math.abs(time) % timeline.totalTime);
            }
            else {
                time = 0;
                index = 0;
                return this;
            }
        }
        else if (time > timeline.totalTime) {
            if (looping) {
                time %= timeline.totalTime;
            }
            else {
                time = timeline.totalTime;
                index = timeline.intervals.length - 1;
                return this;
            }
        }
        
        index = 0;
        var end:Int = timeline.intervals.length;
        while ((end - index) > 1) {
            var mid:Int = (index + end) >> 1;
            if (timeline.accumulations[mid] < time) {
                index = mid;
            }
            else {
                end = mid;
            }
        }
        
        return this;
    }
    public function traverse(dt:Float):KeyframeTraverseContext {
        return setToTime(time + dt);
    }
}
