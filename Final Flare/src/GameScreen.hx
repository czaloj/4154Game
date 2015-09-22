package;

import openfl.Lib;

class GameScreen {
    private var screenController:ScreenController;

    public function new() {
        screenController = null;
        inputController = InputController.new()
        stage.addEventListener(KeyboardEvent.KEY_DOWN, inputController.keyDown);
        stage.addEventListener(KeyboardEvent.KEY_UP, inputController.keyUp);
    }

    public function setParentController(sc:ScreenController):Void {
        screenController = sc;
    }

    public function update(gameTime:GameTime):Void
    {
        throw "abstract";
    }
    public function draw(gameTime:GameTime):Void
    {
        throw "abstract";
    }
}
