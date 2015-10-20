package;

class CodeLevelEditor {
    public static function drawBox(lvl:GameLevel, id:Int, x:Int, y:Int, w:Int, h:Int, inForeground:Bool = true):Void {
        var blocks:Array<Int> = inForeground ? lvl.foreground : lvl.background;
        for (iy in y...(y + h)) {
            var i:Int = iy * lvl.width + x;
            for (ix in x...(x + w)) {
                blocks[i] = id;
                i++;
            }
        }
    }
    
    public static function run():Void {
        var lvl:GameLevel = new GameLevel();
        lvl.width = 80;
        lvl.height = 40;
        
        // Create the level with only air
        lvl.background = [];
        lvl.background[lvl.width * lvl.height - 1] = 0;
        drawBox(lvl, 0, 0, 0, lvl.width, lvl.height, false);
        lvl.foreground = [];
        lvl.foreground[lvl.width * lvl.height - 1] = 0;
        drawBox(lvl, 0, 0, 0, lvl.width, lvl.height, true);
        
        // Add platforms
        drawBox(lvl, 1, 0, lvl.height - 2, lvl.width, 2, true);
        drawBox(lvl, 2, 0, lvl.height - 4, 10, 2, true);
        
        // Spawning locations
        lvl.playerPt.x = lvl.width / 2 - 2;
        lvl.playerPt.y = 5;
        lvl.spawners = [
            new Spawner("Grunt", 2, 3)
        ];
        
        // Environment
        lvl.environmentSprites = "assets/img/Factory.png";
        lvl.environmentType = "Simple";
        lvl.parallax = [
            "assets/img/FactoryP1.png",
            "assets/img/FactoryP2.png",
            "assets/img/FactoryP3.png",
            "assets/img/FactoryP4.png"
        ];
        
        LevelCreator.saveToFile(lvl);
    }
    
    public function new() {
        // Empty
    }
}
