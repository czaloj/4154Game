package;

import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import game.AIController;
import game.GameLevel;
import game.GameplayController;
import game.GameState;
import game.InputController;
import game.PhysicsController;
import graphics.Renderer;
import graphics.RenderPack;
import graphics.StaticSprite;
import weapon.Weapon;
import weapon.WeaponGenerator;
import weapon.WeaponGenParams;
import openfl.Assets;
import openfl.text.TextFormat;
import openfl.text.TextField;
import openfl.display.Sprite;
import openfl.events.KeyboardEvent;
import openfl.Lib;
import openfl.ui.Keyboard;
import starling.textures.Texture;
import ui.UISpriteFactory;

class GameplayScreen extends IGameScreen {
    private var state:game.GameState;
    private var gameplayController:game.GameplayController;
    private var aiController:game.AIController;
    private var renderer:Renderer;
    public var inputController:game.InputController;
    private var debugPhysicsView:Sprite;
    private var score:TextField;
    private var hp:StaticSprite;

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
        FFLog.recordArenaStart(42, 0);

        state = new game.GameState();
        inputController = new game.InputController();
        gameplayController = new GameplayController();
        aiController = new game.AIController();
        var pack:RenderPack = new RenderPack();

        var gl:game.GameLevel = screenController.loadedLevel;
        LevelCreator.createStateFromLevel(gl, state);
        LevelCreator.modifyFromMenu(screenController.levelModifiers, state);
        gameplayController.init(state);
        LevelCreator.createPackFromLevel(gl, pack);
        renderer = new Renderer(screenController, pack, state);
        gameplayController.setVisualizer(renderer);

        openfl.Lib.current.stage.addEventListener(KeyboardEvent.KEY_DOWN, inputController.keyDown);
        openfl.Lib.current.stage.addEventListener(KeyboardEvent.KEY_UP, inputController.keyUp);
        openfl.Lib.current.stage.addEventListener(MouseEvent.MOUSE_DOWN, inputController.mouseDown);
        openfl.Lib.current.stage.addEventListener(MouseEvent.MOUSE_MOVE, inputController.mouseMove);
        openfl.Lib.current.stage.addEventListener(MouseEvent.MOUSE_UP, inputController.mouseUp);

        // Debug view of physics
        debugPhysicsView = new Sprite();
        gameplayController.initDebug(debugPhysicsView);
        Lib.current.stage.addChild(debugPhysicsView);


        //Score
        score = new TextField();
        var myfmt:TextFormat = new TextFormat();
        myfmt.color = 0xFFFFFF;
        myfmt.size = 36;
        myfmt.bold;
        score.x = 400;
        score.defaultTextFormat = myfmt;
        score.text = Std.string(state.score);
        openfl.Lib.current.stage.addChild(score);

        // TODO: Remove this test code
        var uif:UISpriteFactory = new UISpriteFactory(Texture.fromBitmapData(Assets.getBitmapData("assets/img/UI.png")));
        var hb:StaticSprite = uif.getTile("Health.Background");
        screenController.addChild(hb);

        hp = uif.getTile("Health.Overlay");
        hp.x = 20;
        hp.y = 4;
        hp.width = 201 * state.player.health / 100;
        screenController.addChild(hp);

        Lib.current.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
    }
    override function onExit(gameTime:GameTime):Void {
        FFLog.recordArenaEnd();
        openfl.Lib.current.stage.removeEventListener(KeyboardEvent.KEY_DOWN, inputController.keyDown);
        openfl.Lib.current.stage.removeEventListener(KeyboardEvent.KEY_UP, inputController.keyUp);
        openfl.Lib.current.stage.removeEventListener(MouseEvent.MOUSE_DOWN, inputController.mouseDown);
        openfl.Lib.current.stage.removeEventListener(MouseEvent.MOUSE_UP, inputController.mouseUp);
        Lib.current.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
    }

    override function update(gameTime:GameTime):Void {
        // Update input first
        inputController.update(state, renderer.cameraX, renderer.cameraY, renderer.cameraScale);
        aiController.move(state);

        // Update game logic
        gameplayController.update(state, gameTime);

        //Update score
        score.text = Std.string(state.score);

        //Update Health Bar
        hp.width = 201 * state.player.health / 100;
    }
    override function draw(gameTime:GameTime):Void {
        renderer.update(state);

        // Update the view for the debug physics
        debugPhysicsView.x = renderer.cameraScale * -renderer.cameraX + ScreenController.SCREEN_WIDTH / 2;
        debugPhysicsView.y = renderer.cameraScale * renderer.cameraY + ScreenController.SCREEN_HEIGHT / 2;
        debugPhysicsView.scaleX = renderer.cameraScale / game.PhysicsController.DEBUG_VIEW_SCALE;
        debugPhysicsView.scaleY = -renderer.cameraScale / game.PhysicsController.DEBUG_VIEW_SCALE;
        gameplayController.drawDebug();
    }

    private function onKeyPress(e:KeyboardEvent = null):Void {
        switch (e.keyCode) {
            case Keyboard.F5:
                debugPhysicsView.visible = !debugPhysicsView.visible;
        }
    }
}
