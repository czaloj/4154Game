package ui;

import starling.display.DisplayObjectContainer;
import starling.display.Sprite;
import starling.events.TouchEvent;
import starling.events.TouchPhase;
import starling.text.TextField;
import starling.utils.HAlign;
import starling.utils.VAlign;
import ui.Button.ButtonTextFormat;

typedef ButtonTextFormat = {
    var tx:Int;
    var ty:Int;
    var font:String;
    var size:Int;
    var color:UInt;
    var bold:Bool;
    var hAlign:HAlign;
    var vAlign:VAlign;
}

class Button extends DisplayObjectContainer {
    public var clicked:Bool;
    public var enabled:Bool;
    public var toggle:Bool; //If true, button stays depressed when clicked
    public var upState (default, set):Sprite;
    public var overState (default, set):Sprite;
    public var downState (default, set):Sprite;
    public var hitTestState (default, set):Sprite;
    public var currentState (default, set):Sprite;
    public var bEvent:BroadcastEvent;
    public var bEvent1:BroadcastEvent1<UICharacter>;
    public var customData:Int;
    
    /**
     * Creates a new Button instance.
     * 
     * @param upState      The initial value for the SimpleButton up state.
     * @param overState    The initial value for the SimpleButton over state.
     * @param downState    The initial value for the SimpleButton down state.
     * @param hitTestState The initial value for the SimpleButton hitTest state.
     * @param tog          True if button stays in downState after being pressed. False if the button goes back to upState
     */
    public function new (upState:Sprite = null, overState:Sprite = null, downState:Sprite = null, hitTestState:Sprite = null, text:String = null, btf:ButtonTextFormat = null, tog:Bool = false ) {
        super();
        customData = 0;
        clicked = false;
        enabled = true;
        toggle = tog;
        bEvent = new BroadcastEvent();
        bEvent1 = new BroadcastEvent1<UICharacter>();
        this.upState = (upState != null) ? upState : generateDefaultState ();
        this.overState = (overState != null) ? overState : generateDefaultState ();
        this.downState = (downState != null) ? downState : generateDefaultState ();
        this.hitTestState = (hitTestState != null) ? hitTestState : generateDefaultState ();        
        currentState = this.upState;
        addTextChild(upState, text, btf);
        addTextChild(downState, text, btf);
        addTextChild(overState, text, btf);

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
            
            if (!toggle) {
                this.removeEventListener (TouchEvent.TOUCH, onTouch);
            }
            else {
                this.removeEventListener (TouchEvent.TOUCH, onTouchToggle);
            }
            
            if (hitTestState != null) {
                if (!toggle) {
                    this.addEventListener (TouchEvent.TOUCH, onTouch);
                }
                else {
                    this.addEventListener (TouchEvent.TOUCH, onTouchToggle);
                }
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
    
    public function addTextChild(state:Sprite, text:String, btf:ButtonTextFormat):Void {
        var textField = new TextField(btf.tx, btf.ty, text, btf.font, btf.size, btf.color, btf.bold);
        textField.hAlign = btf.hAlign;
        textField.vAlign = btf.vAlign;
        textField.autoScale = true;
        textField.transformationMatrix.translate(this.width / 2 - textField.width / 2, this.height / 2 - textField.height / 2);
        state.addChild(textField);
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
        if (enabled) {
            if(event.getTouch(this) != null) {
                switch event.getTouch(this).phase {
                    case TouchPhase.BEGAN: 
                        switchState(downState);
                        currentState = downState;
                    case TouchPhase.HOVER: 
                        if (overState != currentState) {
                            switchState(overState);
                            currentState = overState;
                        }
                    case TouchPhase.ENDED:
                        //Change this to fancy shmancy way Cristian uses b?t:f
                        if (!(this.bounds.containsPoint(event.getTouch(this.get_parent()).getLocation(this.get_parent())))) {
                            clicked = false;
                        }
                        else {
                            clicked = true;
                            bEvent.invoke();
                        }
                        switchState(upState);
                        currentState = upState;
                default:
                }
            }
            else 
            {
                switchState(upState);
                currentState = upState;
            }
        }
    }
    
    //Event handler specifically for character select
    private function onTouchToggle (event:TouchEvent):Void {
        if (enabled) {
            if(event.getTouch(this) != null) {
                switch event.getTouch(this).phase {
                    case TouchPhase.BEGAN: 
                        if (currentState == overState) {
                            switchState(downState);
                            currentState = downState; 
                            clicked = true;
                            bEvent.invoke();
                            //bEvent1.invoke(cast(this.parent, UICharacter));
                        }
                        else if (currentState == downState) { 
                            switchState(overState);
                            currentState = upState;
                            //bEvent1.invoke(cast(this.parent, UICharacter));
                            clicked = false;
                        }
                    case TouchPhase.HOVER:
                        if (currentState != downState) {
                            if (overState != currentState) {
                                switchState(overState);
                                currentState = overState;
                            }
                        }
                default:
                }
            }
            else if (!clicked) {
                switchState(upState);
                currentState = upState;
            }
        }
    }
}