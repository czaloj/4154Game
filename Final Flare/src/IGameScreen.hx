package;

import openfl.Lib;
import openfl.events.KeyboardEvent;
import openfl.events.Event;
import openfl.ui.Keyboard;

class IGameScreen {
    private var screenController:ScreenController;

    public function new(sc: ScreenController) {
        screenController = sc;
    }
    
    public function build():Void
    {
        throw "abstract";
    }
    public function destroy():Void
    {
        throw "abstract";
    }
    
    public function onEntry(gameTime:GameTime):Void
    {
        throw "abstract";
    }
    public function onExit(gameTime:GameTime):Void
    {
        throw "abstract";
    }
    
    public function update(gameTime:GameTime):Void
    {
        throw "abstract";
    }
    public function draw(gameTime:GameTime):Void
    {
        throw "abstract";
    }
}
