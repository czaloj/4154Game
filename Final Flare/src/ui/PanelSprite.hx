package ui;
import graphics.PositionalAnimator;
import lime.graphics.console.VertexOutput;
import starling.display.DisplayObject;
import starling.display.DisplayObjectContainer;
import starling.display.Sprite;
import starling.events.Event;

class PanelSprite extends Sprite {
    public var child:DisplayObject;
    private var timeline:KeyframeTimeline;
    private var animator:PositionalAnimator;
    private var state:Float = 0;

    public function new(d:DisplayObject, intervals:Array<Float>, transforms:Array<PAFrame>) {
        super();
        child = d;
        addChild(child);
        
        timeline = new KeyframeTimeline(intervals);
        animator = new PositionalAnimator(timeline, transforms, false);
        
        addEventListener(Event.ADDED_TO_STAGE, onAddStage);
        addEventListener(Event.REMOVED_FROM_STAGE, onRemoveStage);
    }
    
    private function onAddStage(e:Event = null):Void {
        animator.resetTime(0);
        state = 1;
        addEventListener(Event.ENTER_FRAME, onUpdate);
    }
    private function onRemoveStage(e:Event = null):Void {
        removeEventListener(Event.ENTER_FRAME, onUpdate);
    }
    private function onUpdate(e:Event = null):Void {
        var reachEnd:Bool = animator.update(ScreenController.FRAME_TIME * state, child);
        if (state < 0 && reachEnd) {
            mParent.removeChild(this);
        }
    }
    
    public function readdTo(m:DisplayObjectContainer):Void {
        if (mParent != null) {
            animator.resetTime(0);
            extend();
        }
        else {
            m.addChild(this);
        }
    }
    public function extend():Void {
        state = 1;
    }
    public function retract():Void {
        state = -1;
    }
}