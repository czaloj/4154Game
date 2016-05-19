package;

import game.GameLevel;
import game.MenuLevelModifiers;
import openfl.events.KeyboardEvent;
import openfl.Lib;
import openfl.ui.Keyboard;
import sound.Composer;
import starling.display.Sprite;
import starling.events.Event;
import starling.textures.Texture;
import ui.FontLoader;
import ui.UISpriteFactory;
import weapon.WeaponData;
import weapon.Weapon;
import weapon.WeaponGenParams;
import weapon.WeaponLayer;
import weapon.WeaponGenerator;
import openfl.Assets;

class ScreenController extends Sprite {
    public static var FRAME_TIME:Float = 1.0 / 60.0;
    public static inline var SCREEN_WIDTH:Int = 800;
    public static inline var SCREEN_HEIGHT:Int = 450;
    public static inline var VERSION_MAJOR:UInt = 0;
    public static inline var VERSION_MINOR:UInt = 1;
    public static inline var VERSION_REVISION:UInt = 5;
    public static var VERSION_ID:Int = 0 << 16 | 1 << 8 | 2;
    public static inline var LOGGING_DEBUG_MODE:Bool = true;

    public var dt:GameTime = new GameTime();

    private var screens:Array<IGameScreen>; 
    private var activeScreen:IGameScreen;
    private var screenToSwitch:Int = -1;
    
    public var playerData:PlayerData = null;
    public var loadedLevel:GameLevel = null; // The level that has been loaded in by the menu
    public var levelModifiers:MenuLevelModifiers = null; // Additional modification to a level
    public var uif:UISpriteFactory = null;
    
    public function new() {
        super();

        // Register initialization and update functions
        addEventListener(Event.ADDED_TO_STAGE, load);
        openfl.Lib.current.stage.addEventListener(Event.ENTER_FRAME, update);

        // Startup on the splash screen
        screens = [
            new SplashScreen(this),
            new MainMenuScreen(this),
            new LevelSelectScreen(this),
            new GameplayScreen(this),
            new ShopScreen(this),
            new LevelEditorScreen(this),
            new WeaponTestScreen(this),
            new EndScreen(this)
        ];
        activeScreen = screens[0];
        
        Lib.current.stage.addEventListener(KeyboardEvent.KEY_DOWN, function (e:KeyboardEvent):Void {
            switch (e.keyCode) {
                case Keyboard.F6:
                    switchToScreen(3);
                case Keyboard.NUMPAD_5:
                    CodeLevelEditor.run(-1);
                // case Keyboard.F7:
                //     switchToScreen(1);
                case Keyboard.F8:
                    LevelCreator.saveToFile(loadedLevel);
                case Keyboard.F9:
                    WeaponGenerator.composeLayers();
                case Keyboard.NUMPAD_0:
                    if (playerData != null) playerData.reset();
                case Keyboard.F10:
                    switchToScreen(4);
            }
        });
    }

    private function load(e:Event = null):Void {
        // Initialize logging
        FFLog.init(LOGGING_DEBUG_MODE);
        
        // Load persistent assets
        FontLoader.loadFonts();
        Composer.loadTracks();
        uif = new UISpriteFactory(Texture.fromBitmapData(Assets.getBitmapData("assets/img/UI.png")));
        
        // TODO: Load player data
        playerData = new PlayerData("Player");
        levelModifiers = new MenuLevelModifiers();
        var initialWeapons:Array<WeaponData> = WeaponGenerator.generateInitialWeapons();
        levelModifiers.characterWeapons = [
            initialWeapons[0],
            initialWeapons[1],
            initialWeapons[2],
            initialWeapons[3],
            initialWeapons[0], // For testing only
            initialWeapons[4]
        ];
        var weaponParams:WeaponGenParams = new WeaponGenParams();
        weaponParams.evolutionPoints = 500;
        weaponParams.shadynessPoints = 0;
        weaponParams.historicalPoints = 0;
        levelModifiers.enemyWeapons = [WeaponGenerator.generate(weaponParams)];
        weaponParams.evolutionPoints = 1000;
        weaponParams.shadynessPoints = 40;
        levelModifiers.enemyWeapons.push(WeaponGenerator.generate(weaponParams));
        levelModifiers.enemyWeapons.push(WeaponGenerator.generate(weaponParams));
        weaponParams.evolutionPoints = 2000;
        weaponParams.shadynessPoints = 100;
        weaponParams.historicalPoints = 80;
        levelModifiers.enemyWeapons.push(WeaponGenerator.generate(weaponParams));
        levelModifiers.enemyWeapons.push(WeaponGenerator.generate(weaponParams));
        
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
        if (!Composer.isMusicPlaying) {
            Composer.playMusicTrack("Menu" + Std.string(Std.int(Math.random() * 3 + 1))); // TODO: Just tell composer to play menu music
        }
        
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
