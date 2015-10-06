package;

import openfl.Lib;
import openfl.events.KeyboardEvent;
import openfl.Assets;
import haxe.Serializer;
import graphics.RenderPack;
import graphics.Renderer;

class LevelEditorScreen extends IGameScreen {
    private static var BORDER_START = 0;

    public static var MIN_LEVEL_WIDTH:Int = 1600;
    public static var MIN_LEVEL_HEIGHT:Int = 900;

    private var state:GameState;
    private var renderer:Renderer;
    private var gameplayController:GameplayController;

    public var tileMap:TileMap;

    public function new(sc:ScreenController) {
        super(sc);
    }
    
    override public function build():Void {
        // Empty
    }
    override public function destroy():Void {
        // Empty
    }
    
    override public function onEntry(gameTime:GameTime):Void {
        state = new GameState();
        gameplayController = new GameplayController(state);
        var pack:RenderPack = new RenderPack();

        // set up startup level
        var level = new GameLevel();
        level.height = Std.int(MIN_LEVEL_HEIGHT/16);
        level.width = Std.int(MIN_LEVEL_WIDTH/16);
        level.environmentType = "Simple";
        level.environmentSprites = "assets/img/Factory.png";

        tileMap = new TileMap(level.height,level.width);
        level.foreground = tileMap.toIDArray();
        LevelCreator.createFromLevel(level, state, pack);
        renderer = new Renderer(screenController, pack, state);

        for (i in 0...state.width) {
            screenController.addChild(tileMap.getTileByIndex(i).setTileTexture(Tile.BLUE).tile);
        }
        for (i in 0...state.height) {
            screenController.addChild(tileMap.getTileByIndex((i+1)*(state.width-1)).setTileTexture(Tile.BLUE).tile);
            screenController.addChild(tileMap.getTileByIndex(i*(state.width)).setTileTexture(Tile.BLUE).tile);
        }
        // end set up
        

    }
    override public function onExit(gameTime:GameTime):Void {
        // Empty
    }
    
    override public function update(gameTime:GameTime):Void {
        state.foreground = tileMap.toIDArray();
        gameplayController.update(state, gameTime);
    }
    override public function draw(gameTime:GameTime):Void {
        renderer.update(state);
    }
}
