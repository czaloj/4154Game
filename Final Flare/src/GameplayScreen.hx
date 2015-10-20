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
import openfl.display.Sprite;
import openfl.Lib;
import openfl.Assets;
import openfl.events.KeyboardEvent;
import openfl.events.Event;
import openfl.ui.Keyboard;
import starling.display.Quad;
import starling.textures.Texture;
import ui.UISpriteFactory;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import openfl.ui.Keyboard;
import openfl.ui.Mouse;

class GameplayScreen extends IGameScreen {
    private var state:GameState;
    private var gameplayController:GameplayController;
    private var renderer:Renderer;
    public var inputController:InputController;
    private var debugPhysicsView:Sprite;

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
        gameplayController = new GameplayController();
        var pack:RenderPack = new RenderPack();

        // TODO: Remove temp create a level
        // CodeLevelEditor.run();

        var gl:GameLevel = LevelCreator.loadLevelFromFile("assets/level/diamond");
        LevelCreator.createStateFromLevel(gl, state);
        gameplayController.init(state);
        LevelCreator.createPackFromLevel(gl, pack);
        renderer = new Renderer(screenController, pack, state);

        openfl.Lib.current.stage.addEventListener(KeyboardEvent.KEY_DOWN, inputController.keyDown);
        openfl.Lib.current.stage.addEventListener(KeyboardEvent.KEY_UP, inputController.keyUp);

        openfl.Lib.current.stage.addEventListener(MouseEvent.MOUSE_DOWN, inputController.mouseDown);
        openfl.Lib.current.stage.addEventListener(MouseEvent.MOUSE_UP, inputController.mouseUp);
        // Debug view of physics
        debugPhysicsView = new Sprite();
        gameplayController.initDebug(debugPhysicsView);
        Lib.current.stage.addChild(debugPhysicsView);


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
        inputController.update(state, renderer.cameraX, renderer.cameraY, renderer.cameraScale);

        // Update game logic
        Spawner.spawn(gameplayController, state, renderer, gameTime);
        gameplayController.update(state, renderer, gameTime);
    }
    override function draw(gameTime:GameTime):Void {
        renderer.update(state);

        // Update the view for the debug physics
        debugPhysicsView.x = renderer.cameraScale * -renderer.cameraX + ScreenController.SCREEN_WIDTH / 2;
        debugPhysicsView.y = renderer.cameraScale * renderer.cameraY + ScreenController.SCREEN_HEIGHT / 2;
        debugPhysicsView.scaleX = renderer.cameraScale / PhysicsController.DEBUG_VIEW_SCALE;
        debugPhysicsView.scaleY = -renderer.cameraScale / PhysicsController.DEBUG_VIEW_SCALE;
    }
}
