package;

import openfl.Lib;
import openfl.events.KeyboardEvent;
import openfl.events.Event;
import openfl.ui.Keyboard;
import starling.display.Quad;

class GameplayScreen extends IGameScreen {
    private var state:GameState;
    private var gameplayController:GameplayController;
    private var renderer:Renderer;
    public var inputController:InputController;

    public function new(sc: ScreenController) {
        super(sc);
    }

    override function build():Void {
        // Empty
    }
    override function destroy():Void {
        // Empty        
    }
    
    override function onEntry(gameTime:GameTime):Void {
        state = new GameState();
        inputController = new InputController();
        renderer = new Renderer(screenController);
        gameplayController = new GameplayController(state);
        openfl.Lib.current.stage.addEventListener(KeyboardEvent.KEY_DOWN, inputController.keyDown);
        openfl.Lib.current.stage.addEventListener(KeyboardEvent.KEY_UP, inputController.keyUp);
        
        screenController.addChild(new Quad(100, 100, 0xff00ff));
    }
    override function onExit(gameTime:GameTime):Void {
        // Empty
    }
    
    override function update(gameTime:GameTime):Void {
        // Update input first
        inputController.update(state);
        
        // Update game logic
        gameplayController.update(state, gameTime);
    }
    override function draw(gameTime:GameTime):Void {
        renderer.update();
    }
}
