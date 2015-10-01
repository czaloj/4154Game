package;

import flash.events.KeyboardEvent;
import openfl.ui.Keyboard;

/** Handlers for input events **/
class InputController {
    // Array of booleans, indexed by key code.
    // Element is true when corresponding key is pressed. False otherwise.
    private var keysDown:Array<Bool> = [];

    public function new() {
		trace("inputcontroller new");
        // Empty
    }

    // KeyDown handler. Given event e, flips key code element in keysDown to true.
    public function keyDown(e:KeyboardEvent):Void {
        keysDown[e.keyCode] = true;
    }
	
	
	
    // KeyUp handler. Given even e, flips key code element in keysDown to false
    public function keyUp(e:KeyboardEvent):Void {
        keysDown[e.keyCode] = false;
    }
    
    public function update(state:GameState):Void {
        state.player.left = keysDown[Keyboard.A];
        state.player.right = keysDown[Keyboard.D];
		state.player.up = keysDown[Keyboard.W];
        state.player.down = keysDown[Keyboard.S];
    }
}
