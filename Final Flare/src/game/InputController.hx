package game;

import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import game.GameState;
import openfl.ui.Keyboard;

/** Handlers for input events **/
class InputController {
    public static inline var VIEW_LOOKAHEAD:Float = 1000.0;
    
    // Array of booleans, indexed by key code.
    // Element is true when corresponding key is pressed. False otherwise.
    private var keysDown:Array<Bool> = [];
    private var usingMouseInput:Bool = true;
    private var click:Bool;
    private var x:Float; // Location of the mouse
    private var y:Float;
    private var stageHalfWidth:Int;
    private var stageHalfHeight:Int;
    private var lastKeyboardViewDirection:Float = 1.0;

    // Keyboard input variables (configurable)
    public var keyLeft = Keyboard.A;
    public var keyRight = Keyboard.D;
    public var keyJump = Keyboard.W;
    public var keyShootLeft = Keyboard.LEFT;
    public var keyShootRight = Keyboard.RIGHT;
    public var keyShootFlare = Keyboard.SPACE;
    
    public function new() {
        // Empty
    }

    // Raw input event handlers
    public function keyDown(e:KeyboardEvent):Void {
        keysDown[e.keyCode] = true;
    }
    public function keyUp(e:KeyboardEvent):Void {
        keysDown[e.keyCode] = false;
    }
    public function mouseDown(e:MouseEvent):Void {
        click = true;
        x = e.stageX;
        y = e.stageY;
        usingMouseInput = true;
    }
    public function mouseMove(e:MouseEvent):Void {
        x = e.stageX;
        y = e.stageY;
        usingMouseInput = true;
    }
    public function mouseUp(e:MouseEvent):Void {
        click = false;
    }

    public function update(state:game.GameState, camX:Float, camY:Float, camScale:Float):Void {
        state.player.direction = switch([keysDown[keyLeft], keysDown[keyRight]]) {
            case [true, true], [false, false]: 0;
            case [false, true]: 1;
            case [true, false]: -1;
            case _: 0;
        }
        state.player.up = keysDown[keyJump];
        state.player.useWeapon = click;
        
        // Keyboard and mouse targeting logic
        if (keysDown[keyShootLeft]) {
            // Target towards the left
            state.player.targetX = state.player.position.x - VIEW_LOOKAHEAD;
            state.player.targetY = state.player.position.y;
            state.player.useWeapon = true;
            lastKeyboardViewDirection = -1;
            
            // Disable mouse
            usingMouseInput = false;
            click = false;
        }
        else if (keysDown[keyShootRight]) {
            // Target towards the right
            state.player.targetX = state.player.position.x + VIEW_LOOKAHEAD;
            state.player.targetY = state.player.position.y;
            state.player.useWeapon = true;
            lastKeyboardViewDirection = 1;
            
            // Disable mouse
            usingMouseInput = false;
            click = false;
        }
        else if (click || usingMouseInput) {
            // Look towards the mouse
            state.player.targetX = (x - ScreenController.SCREEN_WIDTH / 2) / camScale + camX;
            state.player.targetY = ((ScreenController.SCREEN_HEIGHT - y) - ScreenController.SCREEN_HEIGHT / 2) / camScale + camY;
        }
        else {
            // View in the last known keyboard direction
            state.player.targetX = state.player.position.x + VIEW_LOOKAHEAD * lastKeyboardViewDirection;
            state.player.targetY = state.player.position.y;
        }
    }
}
