package game;
import box2D.common.math.B2Vec2;
import box2D.dynamics.B2Body;
import box2D.dynamics.B2Fixture;
import starling.display.Sprite;
import starling.events.Event;

class Coin extends Sprite {
    public var valueEvolution:Int;
    public var valueHistorical:Int;
    public var valueShadyness:Int;
    
    public var body:B2Body;
    public var fixture:B2Fixture;
    
    public function new(e:Int, h:Int, s:Int) {
        super();
        
        valueEvolution = e;
        valueHistorical = h;
        valueShadyness = s;
        
        addEventListener(Event.ADDED_TO_STAGE, function(e:Event):Void { addEventListener(Event.ENTER_FRAME, update); });
        addEventListener(Event.REMOVED_FROM_STAGE, function(e:Event):Void { removeEventListener(Event.ENTER_FRAME, update); });
    }
    
    private function update(e:Event):Void { 
        var pos:B2Vec2 = body.getPosition();
        x = pos.x;
        y = pos.y;
    }
}