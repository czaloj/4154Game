package;

import game.GameLevel;
import game.GameState;
import game.Spawner;
import game.World;
// import graphics.Renderer;
// import graphics.RenderPack;
import graphics.SpriteSheetRegistry;
import openfl.Lib;
import openfl.geom.Point;
import openfl.ui.Keyboard;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.events.KeyboardEvent;
import starling.utils.Color;
import starling.text.TextField;
import flash.net.FileReference;

class LevelEditorScreen extends IGameScreen {

    private static inline var BOX_WIDTH:Int = 100;
    private static inline var BOX_HEIGHT:Int = 20;
    private static inline var FONT_SIZE:Int = 12;
    private static inline var BOX_FONT:String = "Arial";
    private static var FONT_COLOR:UInt = Color.BLACK;
    private static var CLICK_COLOR:UInt = Color.BLUE;

    private static inline var NUM_EDITORS:Int = 3;
    private static inline var PARENT_EDITOR:Int = 0;
    private static var NUM_SUBS:Array<Int> = [];
    private static inline var SUB_EDITOR:Int = 2;
    private static inline var START_INDEX:Int = 4;

    private static inline var CAMERA_WIDTH:Int = ScreenController.SCREEN_WIDTH - BOX_WIDTH;

    public static var MIN_LEVEL_WIDTH:Int = 1600;
    public static var MIN_LEVEL_HEIGHT:Int = 900;

    private var level:game.GameLevel;
    private var state:game.GameState;
    // private var renderer:Renderer;
    private var levelController:LevelEditorController;

    private var cameraX:Float;
    private var cameraY:Float;
    private var cameraScale:Float;
    private var cameraHalfWidth:Float;
    private var cameraHalfHeight:Float;

    private var options:Array<OptionBox> = [];
    private var editor_num = 0;
    private var editors:Array<String> = ["Layer Editor","Background Editor","Foreground Editor"];
    // private var numLayers:Int = 2; 
    private var sub_editor_num = 0;
    private var sub_editors:Array<Array<String>> = [[],[],[]];
    private var layer_item:Array<Array<String>> = [[],[]];
    private var object_num = 0;
    private var objects:Array<Array<String>> = [["Clear Tile"],["Clear Tile"],["Clear Item"]];
    private var tiles:Array<Array<Int>> = [[],[]];
    private var TILE_SHEET_SET:Bool = false;
    private var TILE_CHILDREN_START:Int;

    public var foregroundMap:TileMap;
    public var backgroundMap:TileMap;

    public function new(sc:ScreenController) {
        super(sc);
    }

    private function onMouseDown(e:MouseEvent):Void {
        // (e.stageX - CAMERA_WIDTH / 2) / cameraScale + cameraX;
        // ((ScreenController.SCREEN_HEIGHT - e.stageY) - ScreenController.SCREEN_HEIGHT / 2) / cameraScale + cameraY;
        if (e.stageX <= BOX_WIDTH) {
            var i:Int = Std.int(e.stageY/BOX_HEIGHT);
            var box = options[i];
            if (i == PARENT_EDITOR) {
                box.bold = true;

            } else if (i == SUB_EDITOR) {
                box.bold = true;

            } else {
                // [i-START_INDEX]
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
            var t:Tile = null;
            var x = ((e.stageX - CAMERA_WIDTH / 2) / cameraScale + cameraX);
            var y = (((ScreenController.SCREEN_HEIGHT - e.stageY) - ScreenController.SCREEN_HEIGHT / 2) / cameraScale + cameraY);
            if (map != null) {
                t = map.getTileByCoords(Std.int(x/World.TILE_HALF_WIDTH),Std.int(y/World.TILE_HALF_WIDTH));
                if (object_num == 0) {
                    switch (sub_editor_num) {
                    case 0: t.clearQuarterTile();
                    case 1: t.clearFullTile();
                    }
                } else {
                    var type = tiles[sub_editor_num][object_num-1];
                    switch (sub_editor_num) {
                    case 0: t.colorQuarterTile(type);
                    case 1: t.colorFullTile(type);
                    }
                }
            } else {
                // object editing
                switch (object_num) {
                case 0: level.playerPt = new Point(x,y);
                case 1: level.spawners.push(new Spawner("Grunt",x,y));
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
                // [i-START_INDEX]
                if (editor_num == 0 && sub_editor_num == 0){
                    object_num = i-START_INDEX;
                    var fileRef:FileReference = new FileReference();
                    fileRef.addEventListener(Event.SELECT, onFileBrowse);
                    fileRef.browse();
                } else {

                }
            }
        } else {

            
        }
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
        level.environmentSprites = fileReference.name;
        var type = fileReference.name.split("/");
        level.environmentType = type[type.length-1].split(".")[0];
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
        switch (e.keyCode) {
        case Keyboard.F8:
            level.foreground = foregroundMap.toIDArray();
            level.background = backgroundMap.toIDArray();
            level.parallax = [];
            for (i in 0...layer_item[0].length) {
                var item = layer_item[0][i];
                if (item != "Add Layer") {
                    level.parallax.push(item);
                }
            }
            LevelCreator.saveToFile(level);
        case Keyboard.W:
            cameraY = Math.max(0 + cameraHalfHeight, cameraY -= cameraScale);
        case Keyboard.A:
            cameraX = Math.max(0 + cameraHalfWidth, cameraY -= cameraScale);
        case Keyboard.S:
            cameraY = Math.min(MIN_LEVEL_HEIGHT - cameraHalfHeight, cameraY += cameraScale);
        case Keyboard.D:
            cameraX = Math.min(MIN_LEVEL_WIDTH - cameraHalfWidth, cameraX += cameraScale);
        }
    }

// private function onMouseMove(e:MouseEvent):Void {
    //     var levelWidth = state.width * World.TILE_HALF_WIDTH;
    //     var levelHeight = state.height * World.TILE_HALF_WIDTH;
    //     var curX = e.stageX/ScreenController.SCREEN_WIDTH;
    //     var curY = e.stageY/ScreenController.SCREEN_HEIGHT;
    //     var cameraHalfWidth = ScreenController.SCREEN_WIDTH / (2 * renderer.cameraScale);
    //     var cameraHalfHeight = ScreenController.SCREEN_HEIGHT / (2 * renderer.cameraScale);
    //     if (curX < ScreenController.SCREEN_WIDTH /(3*renderer.cameraScale)) {
    //         renderer.cameraX = Math.max((0) + cameraHalfWidth, renderer.cameraX-=1);
    //     } else if (curX > ScreenController.SCREEN_WIDTH*2 /(3*renderer.cameraScale)) {
    //         renderer.cameraX = Math.min((levelWidth) - cameraHalfWidth, renderer.cameraX+=1);    
    //     }
    //     if (curX < ScreenController.SCREEN_HEIGHT /(3*renderer.cameraScale)) {
    //         renderer.cameraY = Math.max((0) + cameraHalfHeight, renderer.cameraY-=1);
    //     } else if (curX > ScreenController.SCREEN_HEIGHT*2 /(3*renderer.cameraScale)) {
    //         renderer.cameraY = Math.min((levelHeight) - cameraHalfHeight, renderer.cameraY+=1);
    //     }
    // }

    override public function build():Void {
        // Empty
    }
    override public function destroy():Void {
        // Empty
    }

    override public function onEntry(gameTime:GameTime):Void {
        state = new game.GameState();
        levelController = new LevelEditorController();
        // var pack:RenderPack = new RenderPack();

        // set up startup level
        level = new game.GameLevel();
        level.height = Std.int(MIN_LEVEL_HEIGHT/16);
        level.width = Std.int(MIN_LEVEL_WIDTH/16);
        level.environmentType = "Simple";
        level.environmentSprites = "assets/img/Factory.png";
        level.playerPt = new Point(0,0);
        level.spawners = [];

        foregroundMap = new TileMap(level.height,level.width);
        level.foreground = foregroundMap.toIDArray();
        LevelCreator.createStateFromLevel(level, state);

        // set up camera
        cameraScale = 32;
        cameraHalfWidth = CAMERA_WIDTH / (2*cameraScale);
        cameraHalfHeight = ScreenController.SCREEN_HEIGHT / (2*cameraScale);
        cameraX = cameraHalfWidth;
        cameraY = MIN_LEVEL_HEIGHT - cameraHalfHeight;

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
                sub_editors[i].push("Entity Editor");
                // sub_editors[i].push("Tile Sheet");
            default:
                sub_editors[i].push("Quarter Tiles");
                sub_editors[i].push("Full Tiles");
                sub_editors[i].push("Objects");
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

        layer_item[1].push("Player Spawn");
        layer_item[1].push("Enemy Spawn");

        // for (i in 0...state.width) {
        //     screenController.addChild(tileMap.getTileByIndex(i).setTileTexture(Tile.BLUE).tile);
        // }
        // for (i in 0...state.height) {
        //     screenController.addChild(tileMap.getTileByIndex((i+1)*state.width-1).setTileTexture(Tile.BLUE).tile);
        //     screenController.addChild(tileMap.getTileByIndex(i*state.width).setTileTexture(Tile.BLUE).tile);
        // }
        // end startup level set up

        // Lib.current.stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
        Lib.current.stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
        Lib.current.stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);

        Lib.current.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);

    }
    override public function onExit(gameTime:GameTime):Void {
        // Empty
        Lib.current.stage.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
        Lib.current.stage.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseUp);
        Lib.current.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);

    }

    override public function update(gameTime:GameTime):Void {
        updateOptions();
    }
    override public function draw(gameTime:GameTime):Void {
        // renderer.update(state);
        screenController.removeChildren(TILE_CHILDREN_START);

    }

    public function drawTiles(map:TileMap):Void {
        for (i in 0...map.height) {
            if (i >= cameraY - cameraHalfHeight && i <= cameraY + cameraHalfHeight) {
                for (j in 0...map.width) {
                    if (j >= cameraX - cameraHalfWidth && j <= cameraX + cameraHalfWidth) {
                        screenController.addChild(map.getTileByCoords(i,j).tile);
                    }
                }
            }
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
        case 1: 
            for (i in 0...options.length-START_INDEX) {
                box = options[i+START_INDEX];
                box.text = objects[sub_editor_num][i];
                box.visible = true;
            }
        // Foreground Editor
        case 2: 
            for (i in 0...objects[sub_editor_num].length) {
                box = options[i+START_INDEX];
                box.text = objects[sub_editor_num][i];
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

