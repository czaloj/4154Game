package;

import openfl.Lib;
import openfl.events.KeyboardEvent;
import openfl.events.Event;
import openfl.ui.Keyboard;

class GameplayScreen extends IGameScreen {
    private var state:GameState;
    private var gameplayController:GameplayController;
    private var renderer:Renderer;
    public var inputController:InputController;

    public function new(sc: ScreenController) {
        super(sc);
        
        state = new GameState();
        inputController = new InputController();
        renderer = new Renderer(screenController.stage);
        gameplayController = new GameplayController(state);
        openfl.Lib.current.stage.addEventListener(KeyboardEvent.KEY_DOWN, inputController.keyDown);
        openfl.Lib.current.stage.addEventListener(KeyboardEvent.KEY_UP, inputController.keyUp);
    }

    private function checkKeysDown() {
        state.player.left = inputController.keysDown[Keyboard.A];
        state.player.right = inputController.keysDown[Keyboard.D];
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
