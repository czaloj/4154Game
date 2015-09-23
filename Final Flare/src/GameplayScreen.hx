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

    private function checkKeysDown() {
        state.player.left = inputController.keysDown[Keyboard.A];
        state.player.right = inputController.keysDown[Keyboard.D];
    }

    override function build():Void
    {
        
    }
    override function destroy():Void
    {
        
    }
    
    override function onEntry(gameTime:GameTime):Void
    {
        state = new GameState();
        inputController = new InputController();
        renderer = new Renderer(screenController);
        gameplayController = new GameplayController(state);
        openfl.Lib.current.stage.addEventListener(KeyboardEvent.KEY_DOWN, inputController.keyDown);
        openfl.Lib.current.stage.addEventListener(KeyboardEvent.KEY_UP, inputController.keyUp);
        
        screenController.addChild(new Quad(100, 100, 0xff00ff));
    }
    override function onExit(gameTime:GameTime):Void
    {
        
    }
    
    
    override function update(gameTime:GameTime):Void
    {
        gameplayController.update(state, gameTime);
    }
    override function draw(gameTime:GameTime):Void
    {
        renderer.update();
    }
}
