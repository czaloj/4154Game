package ui;

import openfl.events.MouseEvent;
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
    public function new (upState:Sprite = null, overState:Sprite = null, downState:Sprite = null, hitTestState:Sprite = null, text:String = null, btf:ButtonTextFormat = null) {
        super();
        clicked = false;
        enabled = true;
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
        if(event.getTouch(this) != null) {
            switch event.getTouch(this).phase {
                case TouchPhase.BEGAN: 
                    currentState = downState;
                case TouchPhase.HOVER: 
                    if (overState != currentState) {
                        currentState = overState;
                    }
                case TouchPhase.ENDED:
                    //Change this to fancy shmancy way Cristian uses b?t:f
                    if (!(this.bounds.containsPoint(event.getTouch(this.get_parent()).getLocation(this.get_parent())))) {
                        clicked = false;
                    }
                    else 
                    {
                        clicked = true;
                    }
                    currentState = upState;
            default:
            }
        }
        else 
        {
            currentState = upState;
        }
    }
}
    
    