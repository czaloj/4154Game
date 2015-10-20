package;

import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import openfl.ui.Keyboard;
import openfl.ui.Mouse;


/** Handlers for input events **/
class InputController {
    // Array of booleans, indexed by key code.
    // Element is true when corresponding key is pressed. False otherwise.
    private var keysDown:Array<Bool> = [];
    private var click:Bool;
    private var x:Float;
    private var y:Float;
    private var stageHalfWidth:Int;
    private var stageHalfHeight:Int;

    public function new() {
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
    
    public function mouseDown(e:MouseEvent):Void {
        click = true;
        x = e.stageX;
        y = e.stageY;
       // trace(y);
    }
    
    public function mouseUp(e:MouseEvent):Void {
        click = false;
    }

    public function update(state:GameState, camX:Float, camY:Float, camScale:Float):Void {
        state.player.left = keysDown[Keyboard.A];
        state.player.right = keysDown[Keyboard.D];
        state.player.up = keysDown[Keyboard.W];
        state.player.down = keysDown[Keyboard.S];
        state.player.click = click;
        if (click) {
            state.player.targetX = (x - ScreenController.SCREEN_WIDTH / 2) / camScale + camX;
            state.player.targetY = ((ScreenController.SCREEN_HEIGHT - y) - ScreenController.SCREEN_HEIGHT / 2) / camScale + camY;
            click = false;
        }
    }

    /****************************************************************************/
    /* Handlers for level editor */

}
