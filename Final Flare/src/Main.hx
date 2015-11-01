package;

import flash.display.Sprite;
import flash.Lib;
import starling.core.Starling;
import weapon.PartName;
import game.Statistic;

class Main extends Sprite {
    private var engine:Starling;

    public function new () {
        super();
        engine = new Starling(ScreenController, Lib.current.stage);
        engine.start();
    }
}
