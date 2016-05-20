package;

import game.GameLevel;
import game.Spawner;
import game.Region;
import graphics.SpriteSheetRegistry;
import haxe.ds.IntMap;
import openfl.Lib;
import openfl.Assets;
import openfl.geom.Point;
import openfl.ui.Keyboard;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.events.KeyboardEvent;
import starling.utils.Color;
import starling.text.TextField;
import starling.display.Quad;
import starling.display.Image;
import starling.textures.Texture;
import flash.net.FileReference;

class LevelEditorScreen extends IGameScreen {

    public static var LEVEL_WIDTH:Int = 1600;
    public static var LEVEL_HEIGHT:Int = 900;

    private static inline var TILE_HALF_WIDTH = 16;

    private static inline var BOX_WIDTH:Int = 100;
    private static inline var BOX_HEIGHT:Int = 20;
    private static inline var FONT_SIZE:Int = 12;
    private static inline var BOX_FONT:String = "Arial";
    private static var FONT_COLOR:UInt = Color.BLACK;
    private static var CLICK_COLOR:UInt = Color.BLUE;

    private static inline var NUM_EDITORS:Int = 4;
    private static inline var PARENT_EDITOR:Int = 0;
    private static var NUM_SUBS:Array<Int> = [];
    private static inline var SUB_EDITOR:Int = 2;
    private static inline var START_INDEX:Int = 4;

    private static inline var CAMERA_WIDTH:Int = ScreenController.SCREEN_WIDTH - BOX_WIDTH;
    private static var CAMUP = Keyboard.W;
    private static var CAMLEFT = Keyboard.A;
    private static var CAMDOWN = Keyboard.S;
    private static var CAMRIGHT = Keyboard.D;

    private static var REGION_COLOR:UInt = 0xbdbdbd;

    private var level:GameLevel = new GameLevel();

    private var cameraX:Float;
    private var cameraY:Float;
    private var cameraScale:Float;
    private var cameraHalfWidth:Float;
    private var cameraHalfHeight:Float;
    private var cameraMove:Array<Bool> = [];

    private var options:Array<OptionBox> = [];

    private var editor_num = 0;
    private var editors:Array<String> = ["Layer Editor","Background Editor","Foreground Editor","Environment Editor"];
    
    private var sub_editor_num = 0;
    private var sub_editors:Array<Array<String>> = [[],[],[],[]];
    
    private var layer_item:Array<Array<String>> = [[],[]];
    
    private var object_num = 0;
    private var objects:Array<Array<String>> = [["Clear Tile"],["Clear Tile"],["Clear Item"]];
    
    private var tiles:Array<Array<Int>> = [[],[]];
    
    private var env_item:Array<Array<String>> = [[],[],[]];
    
    private var cur_region:Point = new Point(0, 0);
    private var regions:Array<Quad> = [null];
    private var connections:Array<Array<Dynamic>> = [[]];
    private var selected_region:Int = 0;
    private var walkArrow:Texture = Texture.fromBitmapData(Assets.getBitmapData("assets/img/LevelEditor/WalkArrow.png"));
    private var jumpArrow:Texture = Texture.fromBitmapData(Assets.getBitmapData("assets/img/LevelEditor/JumpArrow.png"));
    private var REGION_SELECTED:Bool = false;

    private var TILE_SHEET_SET:Bool = false;
    private var TILE_CHILDREN_START:Int;

    public var foregroundMap:TileMap = new TileMap(Std.int(LEVEL_HEIGHT/TILE_HALF_WIDTH),
        Std.int(LEVEL_WIDTH/TILE_HALF_WIDTH));
    public var backgroundMap:TileMap = new TileMap(Std.int(LEVEL_HEIGHT/TILE_HALF_WIDTH),
        Std.int(LEVEL_WIDTH/TILE_HALF_WIDTH));
    
    public var regionMap:TileMap = new TileMap(Std.int(LEVEL_HEIGHT/TILE_HALF_WIDTH),
        Std.int(LEVEL_WIDTH/TILE_HALF_WIDTH));
    public var numRegions:Int = 0;

    public function new(sc:ScreenController) {
        super(sc);
    }

    private function onMouseDown(e:MouseEvent):Void {
        if (e.stageX <= BOX_WIDTH) {
            var i:Int = Std.int(e.stageY/BOX_HEIGHT);
            var box = options[i];
            if (i == PARENT_EDITOR) {
                box.bold = true;

            } else if (i == SUB_EDITOR) {
                box.bold = true;

            } else {
                if (editor_num == 0) {
                    box.bold = true;
                } else {
                    box = options[object_num+START_INDEX];
                    box.color = FONT_COLOR;
                    box = options[i];
                    box.color = CLICK_COLOR;
                    object_num = i-START_INDEX;
                }
            }
        } else {
            var map:TileMap = null;
            switch (editor_num) {
            case 1: map = backgroundMap;
            case 2: map = foregroundMap;
            }
            var x = (e.stageX - cameraHalfWidth - BOX_WIDTH + cameraX)/TILE_HALF_WIDTH;
            var y = (e.stageY - cameraHalfHeight + cameraY)/TILE_HALF_WIDTH;
            if (map != null) {
                // tile editing
                var tx = Std.int(x);
                var ty = Std.int(y);
                if (object_num == 0) {
                    switch (sub_editor_num) {
                    case 0: map.clearQuarterTile(tx,ty);
                    case 1: map.clearFullTile(tx,ty);
                    }
                } else {
                    var color = tiles[sub_editor_num][object_num-1];
                    switch (sub_editor_num) {
                    case 0: map.setID(tx,ty,color);
                    case 1: map.setFullTile(tx,ty,color);
                    }
                }
                Lib.current.stage.addEventListener(MouseEvent.MOUSE_MOVE, paintTiles);
            } else { // environment editing
                var tx = Std.int(x);
                var ty = Std.int(y);
                var wx = tx * TILE_HALF_WIDTH;
                var wy = ty * TILE_HALF_WIDTH;
                switch (sub_editor_num) {
                case 0: // entity placement
                    var ly = level.height - y;
                    switch (object_num) {
                    case 0: level.playerPt = new Point(x,ly);
                    case 1: level.spawners.push(new Spawner("Grunt",x,ly));
                    case 2: level.spawners.push(new Spawner("Shooter",x,ly));
                    case 3: level.spawners.push(new Spawner("Tank",x,ly));
                    case 4:
                        for (i in 0...level.spawners.length) {
                            var s = level.spawners[i];
                            if (x >= s.position.x && x <= s.position.x+1 &&
                                ly >= s.position.y - 2 && ly <= s.position.y) {
                                level.spawners.remove(s);
                            }
                        }
                    }
                case 1: // regions
                    switch (object_num) {
                    case 0: // delete
                        for (i in 1...regions.length) {
                            var r = regions[i];
                            if (r != null && r.visible && wx >= r.x && wx <= r.x+r.width && wy >= r.y && wy <= r.y+r.height) {
                                r.visible = false;
                            }
                        }
                    case 1: // draw
                        regionMap.setID(tx,ty,++numRegions);
                        connections.push([]);
                        regions[numRegions] = new Quad(TILE_HALF_WIDTH,TILE_HALF_WIDTH,REGION_COLOR);
                        regions[numRegions].alpha = .25;
                        regions[numRegions].x = wx;
                        regions[numRegions].y = wy;
                        cur_region = new Point(tx,ty);
                        Lib.current.stage.addEventListener(MouseEvent.MOUSE_MOVE, defRegion);
                    }
                case 2: // link regions
                    if (REGION_SELECTED) {
                        for (i in 1...regions.length) {
                            var r = regions[i];
                            if (r!= null && r.visible && wx >= r.x && wx <= r.x+r.width && wy >= r.y && wy <= r.y+r.height) {
                                switch (object_num) {
                                case 0: // delete
                                    for (c in connections[selected_region]) {
                                        if (c.reg == i) {
                                            connections[selected_region].remove(c);
                                        }
                                    }
                                case 1,2,3,4:
                                    connections[selected_region].push({reg : i, flag : object_num});
                                }
                            }
                        }
                        REGION_SELECTED = false;
                        regions[selected_region].alpha = .25;
                    } else {
                        for (i in 1...regions.length) {
                            var r = regions[i];
                            if (r!= null && r.visible && wx >= r.x && wx <= r.x+r.width && wy >= r.y && wy <= r.y+r.height) {
                                REGION_SELECTED = true;
                                selected_region = i;
                                regions[selected_region].alpha = .5;
                            }
                        }
                    }
                }
            }
        }
    }

    private function onMouseUp(e:MouseEvent):Void {
        if (e.stageX <= BOX_WIDTH) {
            var i:Int = Std.int(e.stageY/BOX_HEIGHT);
            var box = options[i];
            box.bold = false;
            if (i == PARENT_EDITOR) {
                if (!TILE_SHEET_SET) {
                    var fileRef:FileReference = new FileReference();
                    fileRef.addEventListener(Event.SELECT, findSheet);
                    fileRef.browse();
                }
                editor_num = (editor_num + 1) % NUM_EDITORS;
                sub_editor_num = 0;
                updateOptions();
                box = options[object_num+START_INDEX];
                box.color = FONT_COLOR;
                object_num = 0;
            } else if (i == SUB_EDITOR) {
                sub_editor_num = (sub_editor_num + 1) % NUM_SUBS[editor_num];
                updateOptions();
                box = options[object_num+START_INDEX];
                box.color = FONT_COLOR;
                object_num = 0;
            } else {
                if (editor_num == 0 && sub_editor_num == 0){
                    object_num = i-START_INDEX;
                    var fileRef:FileReference = new FileReference();
                    fileRef.addEventListener(Event.SELECT, onFileBrowse);
                    fileRef.browse();
                } else {

                }
            }
        } else {
            switch (editor_num) {
            case 1,2:
                Lib.current.stage.removeEventListener(MouseEvent.MOUSE_MOVE, paintTiles);
            case 3:
                switch (sub_editor_num) {
                case 1: 
                    Lib.current.stage.removeEventListener(MouseEvent.MOUSE_MOVE, defRegion);
                    var r = regions[numRegions];
                    for (i in 0...Std.int(r.width/TILE_HALF_WIDTH)) {
                        for (j in 0 ...Std.int(r.height/TILE_HALF_WIDTH)) {
                            regionMap.setID(i,j,numRegions);
                        }
                    }
                }
            }
        }
    }

    private function paintTiles(e:MouseEvent):Void {
        var map:TileMap = null;
        switch (editor_num) {
        case 1: map = backgroundMap;
        case 2: map = foregroundMap;
        }
        var x = Std.int((e.stageX - cameraHalfWidth - BOX_WIDTH + cameraX)/TILE_HALF_WIDTH);
        var y = Std.int((e.stageY - cameraHalfHeight + cameraY)/TILE_HALF_WIDTH);
        if (object_num == 0) {
            switch (sub_editor_num) {
            case 0: map.clearQuarterTile(x,y);
            case 1: map.clearFullTile(x,y);
            }
        } else {
            var color = tiles[sub_editor_num][object_num-1];
            switch (sub_editor_num) {
            case 0: map.setID(x,y,color);
            case 1: map.setFullTile(x,y,color);
            }
        }
        regions[numRegions].width = Math.max(x - cur_region.x,1)*TILE_HALF_WIDTH;
        regions[numRegions].height = Math.max(y - cur_region.y,1)*TILE_HALF_WIDTH;
    }

    private function defRegion(e:MouseEvent):Void {
        var x = Std.int((e.stageX - cameraHalfWidth - BOX_WIDTH + cameraX)/TILE_HALF_WIDTH);
        var y = Std.int((e.stageY - cameraHalfHeight + cameraY)/TILE_HALF_WIDTH);
        regions[numRegions].width = Math.max(x - cur_region.x,1)*TILE_HALF_WIDTH;
        regions[numRegions].height = Math.max(y - cur_region.y,1)*TILE_HALF_WIDTH;
    }

    private function findSheet(e:Event):Void {
        var fileReference:FileReference = cast(e.target, FileReference);
        fileReference.removeEventListener(Event.SELECT, findSheet);
        fileReference.addEventListener(Event.COMPLETE, loadSheet);

        fileReference.load();
    }

    private function loadSheet(e:Event):Void {
        var fileReference:FileReference = cast(e.target, FileReference);
        fileReference.removeEventListener(Event.COMPLETE, onFileLoaded);

        TILE_SHEET_SET = true;
        var type = fileReference.name.split("/");
        level.environmentType = type[type.length-1].split(".")[0];
        level.environmentSprites = "assets/img/" + level.environmentType + ".png";
    }

    private function onFileBrowse(e:Event):Void {
        var fileReference:FileReference = cast(e.target, FileReference);
        fileReference.removeEventListener(Event.SELECT, onFileBrowse);
        fileReference.addEventListener(Event.COMPLETE, onFileLoaded);

        fileReference.load();
    }

    private function onFileLoaded(e:Event):Void {
        var fileReference:FileReference = cast(e.target, FileReference);
        fileReference.removeEventListener(Event.COMPLETE, onFileLoaded);

        var box = options[object_num+START_INDEX];
        box.text = fileReference.name;
        layer_item[0][object_num] = fileReference.name;
    }

    private function onKeyDown(e:KeyboardEvent):Void {
        cameraMove[e.keyCode] = true;

        if (e.keyCode == Keyboard.F7) {
            level.foreground = foregroundMap.tmap;
            level.background = backgroundMap.tmap;
            level.parallax = [];
            for (i in 0...layer_item[0].length) {
                var item = layer_item[0][i];
                if (item != "Add Layer") {
                    level.parallax.push("assets/img/" + level.environmentType + "/" + item);
                }
            }
            // fill in region information
            level.nregions = numRegions;
            level.regionLists = new IntMap<Region>();
            for (i in 1...regions.length) {
                var r = regions[i];
                if (r!= null && r.visible) {
                    var reg = new Region(i);
                    reg.minPoint = new Point((r.x) / TILE_HALF_WIDTH,(r.y) / TILE_HALF_WIDTH);
                    reg.maxPoint = new Point((r.x + r.width) / TILE_HALF_WIDTH,(r.y + r.height) / TILE_HALF_WIDTH);
                    reg.position = new Point((r.x + r.width/2) / TILE_HALF_WIDTH,(r.y + r.height/2) / TILE_HALF_WIDTH);
                    level.regionLists.set(i,reg);
                }
            }
            for (r in level.regionLists) {
                var conns = connections[r.id];
                if (conns!= null && conns.length > 0) {
                    for (c in conns) {
                        r.addNeighbor(level.regionLists.get(c.reg),c.flag);
                        level.regionLists.set(r.id,r);
                    }
                }
            }

            screenController.removeChildren();
            screenController.loadedLevel = level;
            screenController.switchToScreen(3);
        }
        if (e.keyCode == Keyboard.F5) {
            var fileRef:FileReference = new FileReference();
            fileRef.addEventListener(Event.SELECT, findLevel);
            fileRef.browse();
        }
    }

    private function findLevel(e:Event):Void {
        var fileReference:FileReference = cast(e.target, FileReference);
        fileReference.removeEventListener(Event.SELECT, findLevel);
        fileReference.addEventListener(Event.COMPLETE, loadLevel);

        fileReference.load();
    }

    private function loadLevel(e:Event):Void {
        var fileReference:FileReference = cast(e.target, FileReference);
        fileReference.removeEventListener(Event.COMPLETE, loadLevel);

        level = LevelCreator.loadLevelFromFile("assets/level/" + fileReference.name);
        LEVEL_HEIGHT = level.height*TILE_HALF_WIDTH;
        LEVEL_WIDTH = level.width*TILE_HALF_WIDTH;
        foregroundMap.tmap = level.foreground;
        backgroundMap.tmap = level.background;
        for (i in 0...level.parallax.length) {
            var l = level.parallax[i].split("/");
            layer_item[0][i] = l[l.length-1];
        }
        numRegions = level.nregions;
        regionMap.tmap = level.regions;
        for (r in level.regionLists) {
            regions[r.id] = new Quad(r.minPoint.x+r.maxPoint.x,r.minPoint.y+r.maxPoint.y,REGION_COLOR);
            regions[r.id].x = r.minPoint.x;
            regions[r.id].y = r.minPoint.y;
            regions[r.id].alpha = .25;

            connections[r.id] = [];
            for (n in r.neighbors) {
                connections[r.id].push({reg:n.region, flag:n.direction});
            }
        }

        cameraY = LEVEL_HEIGHT - cameraHalfHeight;

        TILE_SHEET_SET = true;
    }

    private function onKeyUp(e:KeyboardEvent):Void {
        cameraMove[e.keyCode] = false;
    }

    override public function build():Void {
        // Empty
    }
    override public function destroy():Void {
        // Empty
    }

    override public function onEntry(gameTime:GameTime):Void {
        // set up level
        level.height = Std.int(LEVEL_HEIGHT/TILE_HALF_WIDTH);
        level.width = Std.int(LEVEL_WIDTH/TILE_HALF_WIDTH);

        // set up camera
        cameraScale = 1;
        cameraHalfWidth = CAMERA_WIDTH / (2*cameraScale);
        cameraHalfHeight = ScreenController.SCREEN_HEIGHT / (2*cameraScale);
        cameraX = cameraHalfWidth;
        cameraY = LEVEL_HEIGHT - cameraHalfHeight;

        // set up UI
        for (i in 0...Std.int(ScreenController.SCREEN_HEIGHT/BOX_HEIGHT)) {
            var box = new OptionBox(BOX_WIDTH,BOX_HEIGHT,editors[editor_num],BOX_FONT,FONT_SIZE,FONT_COLOR);
            box.y += i*BOX_HEIGHT;
            box.autoScale = true;
            options[i] = box;
            screenController.addChild(box);

            layer_item[0].push("Add Layer");
        }
        TILE_CHILDREN_START = screenController.numChildren;

        for (i in 0...NUM_EDITORS) {
            switch i {
            case 0:
                sub_editors[i].push("Parallax Editor");
            case 1,2:
                sub_editors[i].push("Quarter Tiles");
                sub_editors[i].push("Full Tiles");
                sub_editors[i].push("Objects");
            case 3:
                sub_editors[i].push("Entity Placement");
                sub_editors[i].push("Region Editor");
                sub_editors[i].push("Region Links Editor");
            }
            NUM_SUBS.push(sub_editors[i].length);
        }

        for (i in 1...Tile.NUM_TILES+1) {
            if (SpriteSheetRegistry.isHalfTile(i)) {
                objects[0].push(SpriteSheetRegistry.getSheetName(i));
                tiles[0].push(i);
            } else {
                objects[1].push(SpriteSheetRegistry.getSheetName(i));
                tiles[1].push(i);
            }
        }

        for (i in 0...level.width) {
            foregroundMap.setFullTileByIndex(i,tiles[1][0]);
            foregroundMap.setFullTile(i,level.height-2,tiles[1][0]);
        }
        for (i in 0...level.height-2) {
            foregroundMap.setFullTile(0,2*i,tiles[1][0]);
            foregroundMap.setFullTile(level.width-2,2*i,tiles[1][0]);
        }

        env_item[0].push("Player Spawn");
        env_item[0].push("Grunt Spawn");
        env_item[0].push("Shooter Spawn");
        env_item[0].push("Tank Spawn");
        env_item[0].push("Remove Enemy");
        env_item[1].push("Remove Region");
        env_item[1].push("Draw Region");
        env_item[2].push("Clear");
        env_item[2].push("Walk Left");
        env_item[2].push("Walk Right");
        env_item[2].push("Jump Left");
        env_item[2].push("Jump Right");

        Lib.current.stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
        Lib.current.stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);

        Lib.current.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
        Lib.current.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
    }
    override public function onExit(gameTime:GameTime):Void {
        Lib.current.stage.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
        Lib.current.stage.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseUp);
        Lib.current.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
        Lib.current.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp);
    }

    override public function update(gameTime:GameTime):Void {
        updateOptions();
        // update camera
        if (cameraMove[CAMUP]) {
            cameraY = Math.max(0 + cameraHalfHeight, cameraY -= 2*TILE_HALF_WIDTH);
        } if (cameraMove[CAMLEFT]) {
            cameraX = Math.max(0 + cameraHalfWidth, cameraX -= 2*TILE_HALF_WIDTH);
        } if (cameraMove[CAMDOWN]) {
            cameraY = Math.min(LEVEL_HEIGHT - cameraHalfHeight, cameraY += 2*TILE_HALF_WIDTH);
        } if (cameraMove[CAMRIGHT]) {
            cameraX = Math.min(LEVEL_WIDTH - cameraHalfWidth, cameraX += 2*TILE_HALF_WIDTH);
        }
    }

    override public function draw(gameTime:GameTime):Void {
        screenController.removeChildren(TILE_CHILDREN_START);
        
        drawTiles(backgroundMap);
        drawTiles(foregroundMap);
        
        drawSpawner(level.playerPt,Color.BLUE);
        for (i in level.spawners) {
            drawSpawner(i.position,Color.RED);
        }

        for (i in 1...regions.length) {
            var r = regions[i];
            if (r != null && r.visible && r.x >= cameraX - cameraHalfWidth && r.x + r.width <= cameraX + cameraHalfWidth &&
                r.y + r.height >= cameraY - cameraHalfHeight && r.y <= cameraY + cameraHalfHeight) {
                var rr = new Quad(r.width,r.height,REGION_COLOR);
                rr.alpha = r.alpha;
                rr.x = r.x - cameraX + cameraHalfWidth + BOX_WIDTH;
                rr.y = r.y - cameraY + cameraHalfHeight;
                screenController.addChild(rr);

                for (c in connections[i]) {
                    var r1 = new Point(r.x + r.width/2, r.y + r.height/2);
                    var rrr = regions[c.reg];
                    var r2 = new Point(rrr.x + rrr.width/2, rrr.y + rrr.height/2);
                    switch c.flag {
                    case 1,2: // walk
                        var arrow = new Image(walkArrow);
                        arrow.rotation = Math.abs(c.flag-2) * Math.PI;
                        arrow.x = r1.x > r2.x ? r1.x - arrow.width/2 : r2.x - arrow.width/2;
                        arrow.x += -cameraX + cameraHalfWidth + BOX_WIDTH;
                        arrow.x += c.flag == Region.RIGHT ? -arrow.width : 0;
                        arrow.x = Math.max(0,arrow.x);
                        var overlap = Math.max(r1.y,r2.y);
                        arrow.y = overlap + (Math.min(r.y+r.height,rrr.y+rrr.height) - overlap)/2;
                        arrow.y += -cameraY + cameraHalfHeight;
                        arrow.y += c.flag == Region.LEFT ? 0 : -2*arrow.height;
                        arrow.y = Math.max(0,arrow.y);
                        screenController.addChild(arrow);
                    case 3,4: // jump
                        var arrow = new Image(jumpArrow);
                        arrow.rotation = Math.abs(c.flag-4) * Math.PI;
                        var x = Math.abs(r1.x - r2.x);
                        var y = Math.abs(r1.y - r2.y);
                        var rot = Math.tan(y/x);
                        if ((r1.x > r2.x && r1.y > r2.y)||(r1.x < r2.x && r1.y < r2.y)) {
                            arrow.rotation += rot;
                        } else arrow.rotation -= rot;
                        arrow.x = r1.x > r2.x ? r1.x - arrow.width/2 : r2.x - arrow.width/2;
                        arrow.x += -cameraX + cameraHalfWidth + BOX_WIDTH;
                        arrow.x += c.flag == Region.JUMP_RIGHT ? -arrow.width : 0;
                        // arrow.x -= arrow.width;
                        arrow.x = Math.max(0,arrow.x);
                        var overlap = Math.max(r1.y,r2.y);
                        arrow.y = overlap + (Math.min(r.y+r.height,rrr.y+rrr.height) - overlap)/2;
                        arrow.y += -cameraY + cameraHalfHeight;
                        arrow.y += c.flag == Region.JUMP_LEFT ? 0 : -arrow.height;
                        arrow.y = Math.max(0,arrow.y);
                        screenController.addChild(arrow);
                    }
                }
            }
        }
    }

    public function drawTiles(map:TileMap):Void {
        for (i in 0...map.height) {
            var iw = i * TILE_HALF_WIDTH;
            if (iw >= cameraY - cameraHalfHeight && iw <= cameraY + cameraHalfHeight) {
                for (j in 0...map.width) {
                    var jw = j * TILE_HALF_WIDTH;
                    var id = Std.int(Math.abs(map.getID(j,i)));
                    if (jw >= cameraX - cameraHalfWidth && jw <= cameraX + cameraHalfWidth && id > 0) {
                        var js = jw - cameraX + cameraHalfWidth + BOX_WIDTH;
                        var is = iw - cameraY + cameraHalfHeight;
                        screenController.addChild(map.drawTile(Std.int(js),Std.int(is),id));
                    }
                }
            }
        }
    }

    public function drawSpawner(p:Point,c:UInt):Void {
        var x = p.x * TILE_HALF_WIDTH;
        var y = (level.height - p.y) * TILE_HALF_WIDTH;
        if (x >= cameraX - cameraHalfWidth && x <= cameraX + cameraHalfWidth &&
            y >= cameraY - cameraHalfHeight && y <= cameraY + cameraHalfHeight) {
            var s = new Quad(TILE_HALF_WIDTH,2*TILE_HALF_WIDTH,c);
            s.alpha = 0.4;
            s.x = x - cameraX + cameraHalfWidth + BOX_WIDTH;
            s.y = y - cameraY + cameraHalfHeight;
            screenController.addChild(s);
        }
    }

    public function updateOptions():Void {
        var box = options[PARENT_EDITOR];
        box.text = editors[editor_num];
        box.visible = true;
        box = options[SUB_EDITOR];
        box.text = sub_editors[editor_num][sub_editor_num];
        box.visible = true;

        switch editor_num {
        // Layer Editor
        case 0: 
            for (i in 0...options.length-START_INDEX) {
                box = options[i+START_INDEX];
                box.text = layer_item[sub_editor_num][i]; 
                box.visible = true;
            }
        // Background Editor
        case 1,2: 
            for (i in 0...options.length-START_INDEX) {
                box = options[i+START_INDEX];
                box.text = objects[sub_editor_num][i];
                box.visible = true;
            }
        // Foreground Editor
        // case 2: 
        //     for (i in 0...objects[sub_editor_num].length) {
        //         box = options[i+START_INDEX];
        //         box.text = objects[sub_editor_num][i];
        //         box.visible = true;
        //     }
        // Environment Editor
        case 3:
            for (i in 0...options.length-START_INDEX) {
                box = options[i+START_INDEX];
                box.text = env_item[sub_editor_num][i];
                box.visible = true;
            }
        }
    }
}

private class OptionBox extends TextField {
    public function new(width:Int, height:Int, text:String, ?fontName:String, ?fontSize:Float, ?color:UInt, ?bold:Bool) {
        super(width, height, text, fontName, fontSize, color, bold);
        this.border = true;
        this.visible = false;
    }
}

