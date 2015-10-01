package;

import graphics.Renderer;
import graphics.RenderPack;
import graphics.SpriteSheet;
import graphics.StaticSprite;
import graphics.StripRegion;
import graphics.TileRegion;
import gun.GunGenerator;
import gun.GunGenParams;
import gun.Gun;
import openfl.display.Graphics;
import openfl.Lib;
import openfl.Assets;
import openfl.events.KeyboardEvent;
import openfl.events.Event;
import openfl.ui.Keyboard;
import starling.display.Quad;
import starling.textures.Texture;
import ui.UISpriteFactory;

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
        level.width = 8;
        level.height = 1;
        level.foreground = [1, 1, 1, 1, 1, 2, 2, 2];
        level.environmentSprites = "assets/img/Factory.png";
        level.environmentType = "Simple";
        
        //TODO: Load Level

        LevelCreator.createFromLevel(level, state, pack);

        renderer = new Renderer(screenController, pack, state);

        openfl.Lib.current.stage.addEventListener(KeyboardEvent.KEY_DOWN, inputController.keyDown);
        openfl.Lib.current.stage.addEventListener(KeyboardEvent.KEY_UP, inputController.keyUp);
        
        // TODO: Remove this test code
        var uif:UISpriteFactory = new UISpriteFactory(Texture.fromBitmapData(Assets.getBitmapData("assets/img/UI.png")));
        var hb:StaticSprite = uif.getTile("Health.Background");
        hb.scaleX *= 2;
        hb.scaleY *= 2;
        screenController.addChild(hb);
        var ggp:GunGenParams = new GunGenParams();
        var gunData = GunGenerator.generate(ggp);
        var gun:Gun = new Gun(gunData);
        
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
        renderer.update(state);
    }
}
