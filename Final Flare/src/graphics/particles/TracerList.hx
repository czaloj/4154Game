package graphics.particles;

import haxe.Constraints.FlatEnum;
import starling.display.Quad;
import starling.display.QuadBatch;


class Instance {
    public var originX:Float;
    public var originY:Float;
    public var width:Float;
    public var length:Float;
    public var angle:Float;
    public var ttl:Float;
    public var initialTTL:Float;
    public var color:UInt;
    
    public function new() {
        // Empty
    }
}

class TracerList extends QuadBatch {
    
    private var instances:Array<Instance>;
    
    public function new() {
        super();
        
        instances = [];
    }
    
    public function add(ox:Float, oy:Float, dx:Float, dy:Float, w:Float, t:Float, color:UInt):Void {
        var i:Instance = new Instance();
        i.originX = ox;
        i.originY = oy;
        i.length = Math.sqrt(dx * dx + dy * dy);
        i.width = w;
        i.ttl = t;
        i.initialTTL = t;
        i.angle = Math.atan2(dy, dx);
        i.color = color;
        instances.push(i);
    }
    public function update(dt:Float):Void {
        // Update and filter particles
        instances = instances.filter(function (i:Instance):Bool {
            i.ttl -= dt;
            return i.ttl > 0;
        });
        
        // Render to the batch
        reset();
        for (i in instances) {
            var q:Quad = new Quad(1, 1);
            q.x = i.originX + Math.sin(i.angle) * i.width * 0.5;
            q.y = i.originY - Math.cos(i.angle) * i.width * 0.5;
            q.height = i.width;
            q.width = i.length;
            q.rotation = i.angle;
            q.alpha = i.ttl / i.initialTTL;
            q.color = i.color;
            addQuad(q);
        }
    }
}
