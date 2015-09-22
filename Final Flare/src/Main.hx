package;

import flash.display.Sprite;
import flash.Lib;
import starling.core.Starling;
import gun.PartName;
import game.Statistic;

class Main extends Sprite {
    
	private var engine:Starling;
    
    public function new () {
        super();
        
        /*var s:Statistic<Float>  = new Statistic<Float>(2.5);
        trace(s.value);
        s.baseValue *= 2;
        trace(s.value);*/
        
        var d:Array<PartName> = [
            new PartName("Noun", PartNameType.NOUN)
        ];
        
        engine = new Starling(ScreenController, Lib.current.stage);
        engine.start();
    }
}