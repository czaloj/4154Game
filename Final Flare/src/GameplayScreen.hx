package;

import graphics.Renderer;
import graphics.RenderPack;
import graphics.SpriteSheet;
import graphics.StripRegion;
import graphics.TileRegion;
import openfl.display.Graphics;
import openfl.Lib;
import openfl.Assets;
import openfl.events.KeyboardEvent;
import openfl.events.Event;
import openfl.ui.Keyboard;
import starling.display.Quad;
import starling.textures.Texture;

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
        gameplayController = new GameplayController(state);

        // TODO: Remove this test code
        var pack:RenderPack = new RenderPack();
        var level = new GameLevel();
        level.width = 100;
        level.height = 100;
        level.foreground = [1, 1, 1, 1, 1, 2, 2, 2];
        //TODO: Load Level

        LevelCreator.createFromLevel(level, state, pack);


        renderer = new Renderer(screenController, pack, state);

        openfl.Lib.current.stage.addEventListener(KeyboardEvent.KEY_DOWN, inputController.keyDown);
        openfl.Lib.current.stage.addEventListener(KeyboardEvent.KEY_UP, inputController.keyUp);
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
