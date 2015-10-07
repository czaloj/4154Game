package;

import openfl.Assets;
import openfl.events.MouseEvent;
import openfl.geom.Rectangle;
import openfl.Lib;
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
        activeScreen = screens[2];
    }

    private function load(e:Event = null):Void {
        for(screen in screens) screen.build();
        activeScreen.onEntry(dt);
    }

    private function update(e:Dynamic = null):Void {
        dt.elapsed = FRAME_TIME;
        dt.total += dt.elapsed;
        dt.frame++;
        
        activeScreen.update(dt);
        activeScreen.draw(dt);
    }
}
