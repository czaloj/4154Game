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
import ui.GameUI;
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
    public  var inputController:game.InputController;
    private var debugPhysicsView:Sprite;
    private var gameUI:GameUI;
    private var uiSheet:UISpriteFactory;

    public function new(sc: ScreenController) {
        super(sc);
    }

    override function build():Void {
        uiSheet = screenController.uif;
    }
    override function destroy():Void {
        // Empty
    }

    override function onEntry(gameTime:GameTime):Void {
        FFLog.recordArenaStart(42, 0);

        state = new game.GameState();
        
        //state.charList = screenController.playerData.selectedChars.copy();
        
        
        inputController = new game.InputController();
        gameplayController = new GameplayController();
        aiController = new game.AIController();
        var pack:RenderPack = new RenderPack();
        pack.uiSheet = uiSheet;

        var gl:game.GameLevel = screenController.loadedLevel;
        LevelCreator.createStateFromLevel(gl, state);
        LevelCreator.createPackFromLevel(gl, pack);
        LevelCreator.modifyFromMenu(screenController.levelModifiers, state, pack);
        gameplayController.init(state);
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
        debugPhysicsView.visible = false;

        // Add the game UI
        gameUI = new GameUI(uiSheet);
        screenController.addChild(gameUI);

        Lib.current.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
    }
    override function onExit(gameTime:GameTime):Void {
        FFLog.recordArenaEnd();
        openfl.Lib.current.stage.removeEventListener(KeyboardEvent.KEY_DOWN, inputController.keyDown);
        openfl.Lib.current.stage.removeEventListener(KeyboardEvent.KEY_UP, inputController.keyUp);
        openfl.Lib.current.stage.removeEventListener(MouseEvent.MOUSE_DOWN, inputController.mouseDown);
        openfl.Lib.current.stage.removeEventListener(MouseEvent.MOUSE_UP, inputController.mouseUp);
        Lib.current.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
        screenController.removeChild(gameUI);
        Lib.current.stage.removeChild(debugPhysicsView);
        renderer.dispose();
    }

    override function update(gameTime:GameTime):Void {
        // Update input first
        inputController.update(state, renderer.cameraX, renderer.cameraY, renderer.cameraScale, gameTime.elapsed);
        aiController.move(state);

        // Update game logic
        gameplayController.update(state, gameTime);
        
        // Go to results when game is over
        if (state.gameOver) {
            screenController.lastKnownState = state;
            screenController.switchToScreen(6);
        }
    }
    override function draw(gameTime:GameTime):Void {
        // Update game renderering
        renderer.update(state);

        // Update game UI
        gameUI.update(state, gameTime.elapsed);

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
            case Keyboard.M:
                screenController.switchToScreen(1);
        }
    }
}
