package ui;

import starling.display.DisplayObjectContainer;
import starling.display.Sprite;
import starling.events.TouchEvent;
import starling.events.TouchPhase;

class Checkbox extends DisplayObjectContainer
{
    public var checked:Bool;
    public var enabled:Bool;
    public var upState (default, set):Sprite;
    public var downState (default, set):Sprite;
    public var hitTestState (default, set):Sprite;
    public var currentState (default, set):Sprite;
    public var bEvent:BroadcastEvent;
    
    /**
     * Creates a new Button instance.
     * 
     * @param upState      The initial value for the SimpleButton up state.
     * @param downState    The initial value for the SimpleButton down state.
     * @param hitTestState The initial value for the SimpleButton hitTest state.
     */
    public function new (upState:Sprite = null, downState:Sprite = null, hitTestState:Sprite = null) {
        super();
        checked = false;
        enabled = true;
        bEvent = new BroadcastEvent();
        this.upState = (upState != null) ? upState : generateDefaultState ();
        this.downState = (downState != null) ? downState : generateDefaultState ();
        this.hitTestState = (hitTestState != null) ? hitTestState : generateDefaultState ();        
        currentState = this.upState;
    }
    
    private function generateDefaultState ():Sprite {
        return new Sprite();
    }
    private function set_upState (upState:Sprite):Sprite {
        if (this.upState != null && currentState == this.upState) currentState = upState;
        return this.upState = upState;
    }
    
    private function set_downState (downState:Sprite):Sprite {
        if (this.downState != null && currentState == this.downState) currentState = downState;
        return this.downState = downState;
    }
    
    private function set_hitTestState (hitTestState:Sprite):Sprite {
        if (hitTestState != this.hitTestState) {
            if (this.hitTestState != null && this.hitTestState.parent == this) {
                removeChild (this.hitTestState);
            }
            this.removeEventListener (TouchEvent.TOUCH, onTouch);
            
            if (hitTestState != null) {
                
                this.addEventListener (TouchEvent.TOUCH, onTouch);                
                hitTestState.alpha = 1;
                addChild (hitTestState);
            }
        }
        return this.hitTestState = hitTestState;
    }
    
    private function set_currentState (state:Sprite):Sprite {
        if (currentState == state) return state;
        switchState (state);
        return currentState = state;
    }
    
    private function switchState (state:Sprite):Void {
        if (currentState != null && currentState.parent == this) {
            removeChild (currentState);
        }
        if (state != null) {
            addChild (state);
        }
    }
    
    //Event Handlers
    override private function onTouch (event:TouchEvent):Void {
        if(event.getTouch(this) != null) {
            switch event.getTouch(this).phase {
                case TouchPhase.BEGAN: 
                    if (currentState == upState) {
                        switchState(downState);
                        currentState = downState; 
                        checked = true;
                    }
                    else if (currentState == downState) { 
                        switchState(upState);
                        currentState = upState;
                        checked = false;
                    }
            default:
            }
        }
    }
}