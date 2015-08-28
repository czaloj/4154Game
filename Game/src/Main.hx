package;

import flash.display.Sprite;
import flash.Lib;
import starling.core.Starling;

class Main extends Sprite {
    private var engine:Starling;
    
    public function new () {
        super();
        
        engine = new Starling(Game, Lib.current.stage);
        engine.start();
    }
}