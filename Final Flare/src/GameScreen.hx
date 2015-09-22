package;

import openfl.Lib;
import openfl.events.KeyboardEvent;
import openfl.events.Event;
import openfl.ui.Keyboard

class GameScreen {

    private var screenController:ScreenController;
    private var gameplayController:GameplayController;
    public var inputController:InputController;

    public function new(sc: ScreenController) {

        inputController = new InputController();
        gameplayController = new GameplayController();
        sc.stage.addEventListener(KeyboardEvent.KEY_DOWN, inputController.keyDown);
        sc.stage.addEventListener(KeyboardEvent.KEY_UP, inputController.keyUp);
        sc.stage.addEventListener(Event.ENTER_FRAME, update());
    }

    public function setParentController(sc:ScreenController):Void {
        screenController = sc;
    }

    private function checkKeysDown() {
        keys = inputController.keysDown;
        gameplayController.playerController.player.left = keys[A];
        gameplayController.playerController.player.right = keys[D];
    }

    public function update(gameTime:GameTime):Void
    {
        gameplayController.update(gameTime);
    }
    public function draw(gameTime:GameTime):Void
    {
        throw "abstract";
    }
}
