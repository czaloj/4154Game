package;

import haxe.ds.IntMap;
import game.GameLevel;
import game.Region;
import game.Spawner;
import openfl.geom.Point;
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

    public static function addRegion(lvl:GameLevel, id:Int, x:Int, y:Int, w:Int, h:Int):Void {
        var region:Region = new Region(id);
        region.minPoint.setTo(x, y);
        region.maxPoint.setTo(x + w, x + h);
        region.position.setTo(0.5 * (region.minPoint.x + region.maxPoint.x), 0.5 * (region.minPoint.y + region.maxPoint.y));
        lvl.regionLists.set(id, region);

        for (iy in y...(y + h)) {
            var i:Int = iy * lvl.width + x;
            for (ix in x...(x + w)) {
                lvl.regions[i] = id;
                i++;
            }
        }
    }
    public static function connectRegion(lvl:GameLevel, idSrc:Int, idDest:Int, jump:Bool):Void {
        // I guess add neighbor with left and right flags coming from center differences
        var r1:Region = lvl.regionLists.get(idSrc);
        var r2:Region = lvl.regionLists.get(idDest);
        if (r1.position.x < r2.position.x) {
            r1.addNeighbor(r2, jump ? 4 : 2);
        }
        else {
            r1.addNeighbor(r2, jump ? 3 : 1);
        }
    }

    public static function run(lvlID:Int = 0):Void {
        var lvl:game.GameLevel = new game.GameLevel();

        switch(lvlID) {
            case 0:
                // Environment
                lvl.width = 100;
                lvl.height = 60;
                lvl.environmentSprites = "assets/img/City.png";
                lvl.environmentType = "Factory";
                lvl.parallax = [
                    "assets/City/P1.png",
                    "assets/City/P2.png",
                    "assets/City/P3.png",
                    "assets/City/P4.png"
                ];
        }

        // Create the level with only air
        lvl.background = [];
        lvl.background[lvl.width * lvl.height - 1] = 0;
        drawBox(lvl, 0, 0, 0, lvl.width, lvl.height, false);
        lvl.foreground = [];
        lvl.foreground[lvl.width * lvl.height - 1] = 0;
        drawBox(lvl, 0, 0, 0, lvl.width, lvl.height, true);

        switch (lvlID) {
            case 0:
                // Add platforms
                drawBox(lvl, 1, 0, 0, 100, 2);
                drawBox(lvl, 1, 0, 54, 100, 6);
                drawBox(lvl, 1, 0, 2, 2, 52);
                drawBox(lvl, 1, 98, 2, 2, 52);
                drawBox(lvl, 1, 2, 2, 44, 2);
                drawBox(lvl, 1, 54, 2, 44, 2);
                drawBox(lvl, 1, 44, 4, 2, 12);
                drawBox(lvl, 1, 54, 4, 2, 12);
                drawBox(lvl, 1, 2, 4, 2, 34);
                drawBox(lvl, 1, 96, 4, 2, 34);
                drawBox(lvl, 1, 4, 16, 14, 4);
                drawBox(lvl, 1, 82, 16, 14, 4);
                drawBox(lvl, 1, 38, 32, 24, 2);
                drawBox(lvl, 1, 26, 38, 20, 2);
                drawBox(lvl, 1, 54, 38, 20, 3);
                drawBox(lvl, 1, 2, 42, 16, 2);
                drawBox(lvl, 1, 82, 42, 16, 2);
                drawBox(lvl, 1, 2, 44, 2, 10);
                drawBox(lvl, 1, 96, 44, 2, 10);
                drawBox(lvl, 1, 4, 50, 4, 4);
                drawBox(lvl, 1, 92, 50, 4, 4);
                drawBox(lvl, 1, 14, 48, 72, 2);
                drawBox(lvl, 1, 32, 46, 36, 2);
                drawBox(lvl, 0, 40, 46, 20, 4);

                // Pathfinding net
                addRegion(lvl, 1, 4, 12, 14, 4);
                addRegion(lvl, 2, 82, 12, 14, 4);

                // Add background
                drawBox(lvl, 27, 20, 18, 60, 30, false);
                drawBox(lvl, 6, 20, 20, 60, 30, false);
                drawBox(lvl, 0, 40, 26, 20, 10, false);

                // Spawning locations
                lvl.playerPt.x = 25;
                lvl.playerPt.y = 20;
                lvl.spawners = [
                    new Spawner("Grunt", 25, 26),
                    new Spawner("Tank", 25, 26),
                    new Spawner("Shooter", 25, 26),
                    new Spawner("Shooter", 1.5, 10),
                    new Spawner("Shooter", 48.5, 10)
                ];
        }

        // Post compute
        lvl.nregions = 0;
        for (region in lvl.regionLists.keys()) {
            lvl.nregions++;
        }
        LevelCreator.saveToFile(lvl);
    }

    public function new() {
        // Empty
    }
}
