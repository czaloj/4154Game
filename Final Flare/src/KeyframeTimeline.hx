package;
import haxe.Timer;

class KeyframeTimeline {
    public var intervals:Array<Float> = [];
    public var accumulations:Array<Float> = [];
    
    public var totalTime(get, never):Float;
    public function get_totalTime():Float {
        return accumulations[accumulations.length - 1];
    }
    
    public function new(intervals:Array<Float>) {
        this.intervals = intervals.copy();
        accumulations = [0.0];
        for (i in 1...(this.intervals.length + 1)) {
            accumulations.push(accumulations[i - 1] + this.intervals[i - 1]);
        }
    }
    
    public function append(t:Float):Void {
        intervals.push(t);
        accumulations.push(totalTime + t);
    }
    public function prepend(t:Float):Void {
        insert(0, t);
    }
    public function insert(i:Int, t:Float):Void {
        intervals.insert(i, t);
        accumulations.push(totalTime + t);
        for (i in (i + 1)...intervals.length) {
            accumulations[i] = accumulations[i - 1] + intervals[i - 1];
        }
    }
}
