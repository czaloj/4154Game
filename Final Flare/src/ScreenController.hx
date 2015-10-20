package;

import flash.net.FileReference;
import haxe.remoting.FlashJsConnection;
import haxe.Unserializer;
import openfl.Assets;
import openfl.events.KeyboardEvent;
import openfl.events.MouseEvent;
import openfl.geom.Rectangle;
import openfl.Lib;
import openfl.ui.Keyboard;
import openfl.utils.ByteArray;
import starling.display.Sprite;
import starling.events.Event;
import starling.utils.AssetManager;
import starling.core.Starling;
import starling.display.Image;
import starling.display.Quad;
import starling.textures.Texture;
import flash.display.BitmapData;

class ScreenController extends Sprite {
    public static var FRAME_TIME:Float = 1.0 / 60.0;
    public static inline var SCREEN_WIDTH:Int = 800;
    public static inline var SCREEN_HEIGHT:Int = 450;

    public var dt:GameTime = new GameTime();

    private var screens:Array<IGameScreen>; 
    private var activeScreen:IGameScreen;
    private var screenToSwitch:Int = -1;
    
    public var loadedLevel:GameLevel = null;

    public function new() {
        super();

        addEventListener(Event.ADDED_TO_STAGE, load);
        openfl.Lib.current.stage.addEventListener(Event.ENTER_FRAME, update);

        // TODO: Start on the splash screen
        screens = [
            new SplashScreen(this),
            new MenuScreen(this),
            new GameplayScreen(this),
            new LevelEditorScreen(this)
        ];
        activeScreen = null;
        
        // TODO: Remove debug level creation
        Lib.current.stage.addEventListener(KeyboardEvent.KEY_DOWN, function (e:KeyboardEvent):Void {
            if (e.keyCode == Keyboard.F6) CodeLevelEditor.run();
        });
        
        // Begin loading a file
        var fileRef:FileReference = new FileReference();
        fileRef.addEventListener(Event.SELECT, onFileBrowse);
        fileRef.browse();
    }

    private function load(e:Event = null):Void {
        for (screen in screens) screen.build();
        if (activeScreen != null) {
            activeScreen.onEntry(dt);
        }
    }
    
    public function switchToScreen(id:Int):Void {
        screenToSwitch = id;
    }

    private function update(e:Dynamic = null):Void {
        // Update game time
        dt.elapsed = FRAME_TIME;
        dt.total += dt.elapsed;
        dt.frame++;
        
        // Logic to switch screens appropriately
        if (screenToSwitch >= 0) {
            if (activeScreen != null) {
                activeScreen.onExit(dt);
            }
            activeScreen = screens[screenToSwitch];
            if (activeScreen != null) {
                activeScreen.onEntry(dt);
            }
            screenToSwitch = -1;
        }
        
        // Update the active screen
        if (activeScreen != null) {
            activeScreen.update(dt);
            activeScreen.draw(dt);
        }
    }

    public function onFileBrowse(e:openfl.events.Event):Void {
        var fileReference:FileReference = cast(e.target, FileReference);
        fileReference.removeEventListener(Event.SELECT, onFileBrowse);
        fileReference.addEventListener(Event.COMPLETE, onFileLoaded);

        fileReference.load();
    }
    public function onFileLoaded(e:openfl.events.Event):Void {
        var fileReference:FileReference = cast(e.target, FileReference);
        fileReference.removeEventListener(Event.COMPLETE, onFileLoaded);

        var data:ByteArray = fileReference.data;
        loadedLevel = cast(Unserializer.run(data.toString()), GameLevel);
        switchToScreen(2);
    }
}
