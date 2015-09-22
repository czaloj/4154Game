package;

/**
 * ...
 * @author Mark
 */
//{ Import Statements
    
    
//}

/** Handlers for input events **/
class InputController extends GameScreen
{
    // Array of booleans, indexed by key code.
    // Element is true when corresponding key is pressed. False otherwise.
    keysDown = [];
    
    // KeyDown handler. Given event e, flips key code element in keysDown to true.
    public function keyDown(e:flash.events.KeyboardEvent):Void 
    {
        keysDown[e.keyCode] = true;
    }

    // KeyUp handler. Given even e, flips key code element in keysDown to false
    public function keyUp(e:flash.events.KeyboardEvent):Void 
    {
        keysDown[e.keyCode] = false;
    }

    //{ Initialization
    public function new() 
    {
        super();
        
    }
    //}


}