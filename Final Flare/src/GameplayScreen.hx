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
        pack.characters = new SpriteSheet(Texture.fromBitmapData(Assets.getBitmapData("assets/img/Man.png")), [        
            new StripRegion("Man.Backflip", 0, 0, 48, 90, 2, 42, 80),        
            new StripRegion("Man.Run", 0, 180, 48, 90, 1, 12, 12),        
            new StripRegion("Man.Idle", 0, 270, 48, 90, 1, 7, 7)        
        ]);
        pack.environment = new SpriteSheet(Texture.fromBitmapData(Assets.getBitmapData("assets/img/Factory.png")), [
            new TileRegion("Brick", 0, 0, 16, 16)
        ]);
        
        renderer = new Renderer(screenController, pack);
        
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
