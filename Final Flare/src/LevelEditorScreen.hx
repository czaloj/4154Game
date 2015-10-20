package;

import game.GameLevel;
import game.GameState;
import game.InputController;
import graphics.Renderer;
import graphics.RenderPack;
import openfl.events.MouseEvent;
import openfl.Lib;

class LevelEditorScreen extends IGameScreen {
    private static var BORDER_START = 0;

    public static var MIN_LEVEL_WIDTH:Int = 1600;
    public static var MIN_LEVEL_HEIGHT:Int = 900;

    private var state:game.GameState;
    private var renderer:Renderer;
    private var levelController:LevelEditorController;

    public var tileMap:TileMap;

    public function new(sc:ScreenController) {
        super(sc);
    }

    private function onMouseMove(e:MouseEvent):Void {
        var levelWidth = state.width * Renderer.TILE_HALF_WIDTH;
        var levelHeight = state.height * Renderer.TILE_HALF_WIDTH;
        var curX = e.stageX/ScreenController.SCREEN_WIDTH;
        var curY = e.stageY/ScreenController.SCREEN_HEIGHT;
        var cameraHalfWidth = ScreenController.SCREEN_WIDTH / (2 * renderer.cameraScale);
        var cameraHalfHeight = ScreenController.SCREEN_HEIGHT / (2 * renderer.cameraScale);
        if (curX < ScreenController.SCREEN_WIDTH /(3*renderer.cameraScale)) {
            renderer.cameraX = Math.max((0) + cameraHalfWidth, renderer.cameraX-=1);
        } else if (curX > ScreenController.SCREEN_WIDTH*2 /(3*renderer.cameraScale)) {
            renderer.cameraX = Math.min((levelWidth) - cameraHalfWidth, renderer.cameraX+=1);    
        }
        if (curX < ScreenController.SCREEN_HEIGHT /(3*renderer.cameraScale)) {
            renderer.cameraY = Math.max((0) + cameraHalfHeight, renderer.cameraY-=1);
        } else if (curX > ScreenController.SCREEN_HEIGHT*2 /(3*renderer.cameraScale)) {
            renderer.cameraY = Math.min((levelHeight) - cameraHalfHeight, renderer.cameraY+=1);
        }
    }

    override public function build():Void {
        // Empty
    }
    override public function destroy():Void {
        // Empty
    }

    override public function onEntry(gameTime:GameTime):Void {
        state = new game.GameState();
        levelController = new LevelEditorController();
        var pack:RenderPack = new RenderPack();

        // set up startup level
        var level = new game.GameLevel();
        level.height = Std.int(MIN_LEVEL_HEIGHT/16);
        level.width = Std.int(MIN_LEVEL_WIDTH/16);
        level.environmentType = "Simple";
        level.environmentSprites = "assets/img/Factory.png";

        tileMap = new TileMap(level.height,level.width);
        level.foreground = tileMap.toIDArray();
        LevelCreator.createStateFromLevel(level, state);
        LevelCreator.createPackFromLevel(level, pack);
        renderer = new Renderer(screenController, pack, state);

        // for (i in 0...state.width) {
        //     screenController.addChild(tileMap.getTileByIndex(i).setTileTexture(Tile.BLUE).tile);
        // }
        // for (i in 0...state.height) {
        //     screenController.addChild(tileMap.getTileByIndex((i+1)*state.width-1).setTileTexture(Tile.BLUE).tile);
        //     screenController.addChild(tileMap.getTileByIndex(i*state.width).setTileTexture(Tile.BLUE).tile);
        // }
        // end startup level set up

        Lib.current.stage.addEventListener(MouseEvent.MOUSE_MOVE,onMouseMove);

    }
    override public function onExit(gameTime:GameTime):Void {
        // Empty
    }

    override public function update(gameTime:GameTime):Void {
        state.foreground = tileMap.toIDArray();
        // gameplayController.update(state, renderer, gameTime);
    }
    override public function draw(gameTime:GameTime):Void {
        // renderer.update(state);
    }
}
