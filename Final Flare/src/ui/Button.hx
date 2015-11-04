package ui;

import openfl.events.MouseEvent;
import starling.display.DisplayObjectContainer;
import starling.display.Sprite;

class Button extends DisplayObjectContainer {
    
    public var enabled:Bool;
    public var upState (default, set):Sprite;
    public var overState (default, set):Sprite;
    public var downState (default, set):Sprite;
    public var hitTestState (default, set):Sprite;
    public var currentState (default, set):Sprite;
    
    
    /**
     * Creates a new Button instance.
     * 
     * @param upState      The initial value for the SimpleButton up state.
     * @param overState    The initial value for the SimpleButton over state.
     * @param downState    The initial value for the SimpleButton down state.
     * @param hitTestState The initial value for the SimpleButton hitTest state.
     */
    public function new (upState:Sprite = null, overState:Sprite = null, downState:Sprite = null, hitTestState:Sprite = null) {
        super ();
        
        enabled = true;        
        this.upState = (upState != null) ? upState : generateDefaultState ();
        this.overState = (overState != null) ? overState : generateDefaultState ();
        this.downState = (downState != null) ? downState : generateDefaultState ();
        this.hitTestState = (hitTestState != null) ? hitTestState : generateDefaultState ();
        
        currentState = this.upState;
    }
    
    private function generateDefaultState ():Sprite {
        return new Sprite ();
    }
    private function set_upState (upState:Sprite):Sprite {
        if (this.upState != null && currentState == this.upState) currentState = upState;
        return this.upState = upState;
    }
    
    private function set_overState (overState:Sprite):Sprite {
        if (this.overState != null && currentState == this.overState) currentState = overState;
        return this.overState = overState;
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
            
            removeEventListener (MouseEvent.MOUSE_DOWN, onMouseDown);
            removeEventListener (MouseEvent.MOUSE_OUT, onMouseOut);
            removeEventListener (MouseEvent.MOUSE_OVER, onMouseOver);
            removeEventListener (MouseEvent.MOUSE_UP, onMouseUp);
            
            if (hitTestState != null) {
                
                addEventListener (MouseEvent.MOUSE_DOWN, onMouseDown);
                addEventListener (MouseEvent.MOUSE_OUT, onMouseOut);
                addEventListener (MouseEvent.MOUSE_OVER, onMouseOver);
                addEventListener (MouseEvent.MOUSE_UP, onMouseUp);
                
                hitTestState.alpha = 0.0;
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
    private function onMouseDown (event:MouseEvent):Void {
        trace("click");
        currentState = downState;
    }
    
    private function onMouseOut (event:MouseEvent):Void {
        if (upState != currentState) {
            currentState = upState;
        }
    }
    
    private function onMouseOver (event:MouseEvent):Void {
        if (overState != currentState) {
            currentState = overState;
        }
    }
    
    private function onMouseUp (event:MouseEvent):Void {
        currentState = overState;
    }
}
    
    