package;

import flash.display.Sprite;
import flash.Lib;
import logging.HeatMapBuilder;
import starling.core.Starling;
import weapon.PartName;
import game.Statistic;

class Main extends Sprite {
    private static inline var PROGRAM_TYPE:Int = 0;
    
    private var engine:Starling;

    public function new () {
        super();
        switch (PROGRAM_TYPE) {
            case 0:
                engine = new Starling(ScreenController, Lib.current.stage);
                engine.start();
            case 1:
                HeatMapBuilder.run("0.1.1");
        }
    }
}
