package game;

import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import game.GameState;
import openfl.ui.Keyboard;

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
    }
    
    public function mouseUp(e:MouseEvent):Void {
        click = false;
    }

    public function update(state:game.GameState, camX:Float, camY:Float, camScale:Float):Void {
        var keyLeft:Bool = keysDown[Keyboard.A];
        var keyRight:Bool = keysDown[Keyboard.D];
        state.player.direction = switch([keyLeft, keyRight]) {
            case [true, true], [false, false]: 0;
            case [false, true]: 1;
            case [true, false]: -1;
        }
        state.player.up = keysDown[Keyboard.W];
        state.player.useWeapon = click;
        
        // Keyboard and mouse targeting logic
        if (keysDown[Keyboard.LEFT]) {
            state.player.targetX = state.player.position.x - 100;
            state.player.targetY = state.player.position.y;
            state.player.useWeapon = true;
            keysDown[Keyboard.LEFT] = false;
            click = false;
        }
        else if (keysDown[Keyboard.RIGHT]) {
            state.player.targetX = state.player.position.x + 100;
            state.player.targetY = state.player.position.y;
            state.player.useWeapon = true;
            keysDown[Keyboard.RIGHT] = false;
            click = false;
        }
        else if (click) {
            state.player.targetX = (x - ScreenController.SCREEN_WIDTH / 2) / camScale + camX;
            state.player.targetY = ((ScreenController.SCREEN_HEIGHT - y) - ScreenController.SCREEN_HEIGHT / 2) / camScale + camY;
            click = false;
        }
    }
}
