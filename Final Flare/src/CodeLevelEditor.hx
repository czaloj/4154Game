package;
import game.GameLevel;
import game.Spawner;
import graphics.SpriteSheetRegistry;

class CodeLevelEditor {
    public static function drawBox(lvl:game.GameLevel, id:Int, x:Int, y:Int, w:Int, h:Int, inForeground:Bool = true):Void {
        var blocks:Array<Int> = inForeground ? lvl.foreground : lvl.background;
        var isFullBlock:Bool = !SpriteSheetRegistry.isHalfTile(id) && id != 0;
        for (iy in y...(y + h)) {
            var i:Int = iy * lvl.width + x;
            for (ix in x...(x + w)) {
                if (isFullBlock && ((((ix - x) & 1) == 1) || (((iy - y) & 1) == 1))) {
                    blocks[i] = -id;
                }
                else {
                    blocks[i] = id;                    
                }
                i++;
            }
        }
    }
    
    public static function run():Void {
        var lvl:game.GameLevel = new game.GameLevel();
        lvl.width = 100;
        lvl.height = 50;
        
        // Create the level with only air
        lvl.background = [];
        lvl.background[lvl.width * lvl.height - 1] = 0;
        drawBox(lvl, 0, 0, 0, lvl.width, lvl.height, false);
        lvl.foreground = [];
        lvl.foreground[lvl.width * lvl.height - 1] = 0;
        drawBox(lvl, 0, 0, 0, lvl.width, lvl.height, true);
        
        // Add platforms
        drawBox(lvl, 1, 0, 48, 100, 2);
        drawBox(lvl, 1, 0, 0, 2, 48);
        drawBox(lvl, 1, 98, 0, 2, 48);
        drawBox(lvl, 4, 2, 43, 30, 1);
        drawBox(lvl, 4, 98 - 30, 43, 30, 1);
        drawBox(lvl, 4, 30, 37, 40, 1);
        drawBox(lvl, 4, 2, 31, 30, 1);
        drawBox(lvl, 21, 98 - 30, 31, 30, 1);
        
        // Add background
        drawBox(lvl, 27, 20, 18, 60, 30, false);
        drawBox(lvl, 6, 20, 20, 60, 30, false);
        drawBox(lvl, 0, 40, 26, 20, 10, false);
        
        // Spawning locations
        lvl.playerPt.x = lvl.width / 2 - 2;
        lvl.playerPt.y = 20;
        lvl.spawners = [
            new game.Spawner("Grunt", 2, 23),
            new game.Spawner("Grunt", 48, 23)
        ];
        
        // Environment
        lvl.environmentSprites = "assets/img/Factory.png";
        lvl.environmentType = "Factory";
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
