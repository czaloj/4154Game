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
                lvl.environmentType = "City";
                lvl.parallax = [
                    "assets/img/City/P1.png",
                    "assets/img/City/P2.png",
                    "assets/img/City/P3.png",
                    "assets/img/City/P4.png"
                ];
            case 1:
                // Environment
                lvl.width = 100;
                lvl.height = 60;
                lvl.environmentSprites = "assets/img/City.png";
                lvl.environmentType = "City";
                lvl.parallax = [
                    "assets/img/Bridges/P1.png",
                    "assets/img/Bridges/P2.png",
                    "assets/img/Bridges/P3.png",
                    "assets/img/Bridges/P4.png"
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
                addRegion(lvl, 1, 0, 0, 100, 60);

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
            case 1:
                // Add platforms
                drawBox(lvl, 1, 0, 0, 100, 2);
                drawBox(lvl, 1, 0, 54, 100, 6);
                drawBox(lvl, 1, 0, 2, 2, 52);
                drawBox(lvl, 1, 98, 2, 2, 52);
                drawBox(lvl, 1, 2, 2, 66, 2);
                drawBox(lvl, 1, 2, 4, 2, 38);
                drawBox(lvl, 1, 4, 10, 12, 4);
                drawBox(lvl, 1, 4, 14, 8, 2);
                drawBox(lvl, 1, 4, 18, 4, 2);
                drawBox(lvl, 1, 18, 24, 16, 2);
                drawBox(lvl, 1, 40, 24, 6, 2);
                drawBox(lvl, 1, 4, 30, 42, 10);
                drawBox(lvl, 0, 34, 30, 6, 8);
                drawBox(lvl, 1, 4, 40, 14, 2);
                drawBox(lvl, 1, 2, 46, 16, 4);
                drawBox(lvl, 1, 46, 50, 10, 4);
                drawBox(lvl, 1, 60, 46, 10, 4);
                drawBox(lvl, 1, 92, 50, 6, 4);
                drawBox(lvl, 1, 92, 44, 6, 2);
                drawBox(lvl, 1, 84, 2, 14, 2);
                drawBox(lvl, 1, 96, 4, 2, 40);
                drawBox(lvl, 1, 58, 4, 4, 18);
                drawBox(lvl, 1, 58, 26, 38, 2);
                drawBox(lvl, 1, 70, 6, 12, 2);
                drawBox(lvl, 1, 74, 8, 4, 14);
                drawBox(lvl, 1, 50, 30, 4, 4);
                drawBox(lvl, 1, 58, 34, 4, 4);
                drawBox(lvl, 1, 66, 38, 4, 4);
                drawBox(lvl, 1, 74, 42, 4, 4);
                drawBox(lvl, 1, 82, 46, 4, 4);

                // Pathfinding net
                addRegion(lvl, 1, 0, 0, 100, 60);

                // Add background
                drawBox(lvl, 27, 20, 18, 60, 30, false);
                drawBox(lvl, 6, 20, 20, 60, 30, false);
                drawBox(lvl, 0, 40, 26, 20, 10, false);

                // Spawning locations
                lvl.playerPt.x = 5.5;
                lvl.playerPt.y = 26;
                lvl.spawners = [
                    new Spawner("Grunt", 38, 28),
                    new Spawner("Tank", 38, 28),
                    new Spawner("Shooter", 38, 28),
                    new Spawner("Grunt", 1.5, 4),
                    new Spawner("Shooter", 1.5, 4),
                    new Spawner("Grunt", 1.5, 8),
                    new Spawner("Tank", 1.5, 8)
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
