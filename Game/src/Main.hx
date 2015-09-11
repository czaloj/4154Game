package;

import flash.display.Sprite;
import flash.Lib;
import starling.core.Starling;
import gun.PartName;

class Main extends Sprite {
    private var engine:Starling;
    
    public function new () {
        super();
        
        var d:Array<PartName> = [
            new PartName("Noun", PartNameType.NOUN)
        ];
        
        engine = new Starling(Game, Lib.current.stage);
        engine.start();
    }
}