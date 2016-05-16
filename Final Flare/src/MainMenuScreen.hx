package;

import starling.display.DisplayObject;
import ui.Button;

class MainMenuScreen extends IGameScreen {
    private var btnPlay:Button;
    private var btnShop:Button;
    
    private var transitioningElements:Array<DisplayObject>
    
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
        // Empty
    }
    override public function onExit(gameTime:GameTime):Void {
        // Empty
    }
    
    override public function update(gameTime:GameTime):Void {
        // Empty
    }
    override public function draw(gameTime:GameTime):Void {
        // Empty
    }
}