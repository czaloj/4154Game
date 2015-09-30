package;

import openfl.Lib;
import openfl.events.KeyboardEvent;
import openfl.Assets;
import haxe.Serializer;
import graphics.RenderPack;
import graphics.Renderer;

class LevelEditorScreen extends IGameScreen {
    private var state:GameState;
    private var renderer:Renderer;

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
        var pack:RenderPack = new RenderPack();
        renderer = new Renderer(screenController, pack, state);

        //TODO: remove this test code
        screenController.addChild(Tile.RED_TILE);
        screenController.addChild(new starling.display.Quad(Renderer.TILE_HALF_WIDTH,Renderer.TILE_HALF_WIDTH,0xff0000));
        screenController.addChild(new starling.display.Quad(10,10,0xffffff));
    }
    override public function onExit(gameTime:GameTime):Void {
        // Empty
    }
    
    override public function update(gameTime:GameTime):Void {
        // Empty
    }
    override public function draw(gameTime:GameTime):Void {
        renderer.update();
    }
}
