package;

import game.GameLevel;
import game.MenuLevelModifiers;
import openfl.events.KeyboardEvent;
import openfl.Lib;
import openfl.ui.Keyboard;
import sound.Composer;
import starling.display.Sprite;
import starling.events.Event;
import ui.FontLoader;
import weapon.WeaponGenerator;

class ScreenController extends Sprite {
    public static var FRAME_TIME:Float = 1.0 / 60.0;
    public static inline var SCREEN_WIDTH:Int = 800;
    public static inline var SCREEN_HEIGHT:Int = 450;
    public static inline var VERSION_MAJOR:UInt = 0;
    public static inline var VERSION_MINOR:UInt = 1;
    public static inline var VERSION_REVISION:UInt = 2;
    public static inline var VERSION_ID:Int = 0 << 16 | 1 << 8 | 2;
    public static inline var LOGGING_DEBUG_MODE:Bool = true;

    public var dt:GameTime = new GameTime();

    private var screens:Array<IGameScreen>; 
    private var activeScreen:IGameScreen;
    private var screenToSwitch:Int = -1;
    
    public var loadedLevel:GameLevel = null; // The level that has been loaded in by the menu
    public var levelModifiers:MenuLevelModifiers = null; // Additional modification to a level
    
    public function new() {
        super();

        // Register initialization and update functions
        addEventListener(Event.ADDED_TO_STAGE, load);
        openfl.Lib.current.stage.addEventListener(Event.ENTER_FRAME, update);

        // Startup on the splash screen
        screens = [
            new SplashScreen(this),
            new MenuScreen(this),
            new GameplayScreen(this),
            new LevelEditorScreen(this)
        ];
        activeScreen = screens[0];
        
        Lib.current.stage.addEventListener(KeyboardEvent.KEY_DOWN, function (e:KeyboardEvent):Void {
            switch (e.keyCode) {
                case Keyboard.F6:
                    // TODO: Remove debug level creation with real level editor
                    CodeLevelEditor.run();
                case Keyboard.F7:
                    switchToScreen(1);
                case Keyboard.F8:
                    LevelCreator.saveToFile(loadedLevel);
                case Keyboard.F9:
                    WeaponGenerator.composeLayers();
            }
        });
    }

    private function load(e:Event = null):Void {
        // Initialize logging
        FFLog.init(LOGGING_DEBUG_MODE);
        
        // Load persistent assets
        FontLoader.loadFonts();
        Composer.loadTracks();
        
        // Create the screens
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
        while (screenToSwitch >= 0) {
            // Buffer screen switching
            var buf:Int = screenToSwitch;
            screenToSwitch = -1;

            // Screens may now switch
            if (activeScreen != null) {
                activeScreen.onExit(dt);
            }
            activeScreen = screens[buf];
            if (activeScreen != null) {
                activeScreen.onEntry(dt);
            }
        }
        
        // Update the active screen
        if (activeScreen != null) {
            activeScreen.update(dt);
            activeScreen.draw(dt);
        }
    }
}
