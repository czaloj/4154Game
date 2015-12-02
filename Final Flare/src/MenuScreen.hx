package;

import game.GameLevel;
import game.MenuLevelModifiers;
import haxe.Unserializer;
import openfl.events.Event;
import flash.net.FileReference;
import flash.utils.ByteArray;
import openfl.geom.Point;
import starling.display.Image;
import ui.LoadoutPane;
import ui.UICharacter;
import ui.UIPane;
import ui.LevelSelectPane;
import weapon.WeaponData;
import weapon.WeaponGenerator;
import weapon.WeaponGenParams;
import ui.Button;
import ui.Button.ButtonTextFormat;
import ui.UISpriteFactory;
import openfl.Assets;
import starling.display.Sprite;
import starling.textures.Texture;
import starling.utils.HAlign;
import starling.utils.VAlign;
import starling.text.TextField;


class MenuScreen extends IGameScreen {
    public static inline var CAMERA_LERP_SPEED:Float = 0.1;
    
    // Camera parameters
    public var camera:Sprite = new Sprite();
    public var origin:Sprite = new Sprite();
    
    public var cameraX(get, set):Float;
    public var cameraY(get, set):Float;
    public var cameraScale(get, set):Float;
    
    
    //UIPanes
    private var mainMenu:UIPane;
    private var homePane:UIPane; //This didn't need any special functionality so it's a generic pane
    private var levelSelectPane:LevelSelectPane;
    private var loadoutPane:LoadoutPane;

    private var uif:UISpriteFactory;  //Buttons are created from UISpriteFactory    
    private var backGround:Image;     //Background
    private var confirmButton:Button; //For squad select pane
    
    public function new(sc:ScreenController) {
        super(sc);
    }
    
    public function get_cameraX():Float {
        return -origin.x;
    }
    public function set_cameraX(v:Float):Float {
        origin.x = -v;
        return v;
    }
    public function get_cameraY():Float {
        return -origin.y;
    }
    public function set_cameraY(v:Float):Float {
        origin.y = -v;
        return v;
    }
    public function get_cameraScale():Float {
        return camera.scaleX;
    }
    public function set_cameraScale(v:Float):Float {
        camera.scaleX = v;
        camera.scaleY = -v;
        return v;
    }
    
    override public function build():Void {
        // Empty
    }
    override public function destroy():Void {
        // Empty
    }

    override public function onEntry(gameTime:GameTime):Void {
        screenController.playerData = new PlayerData("Player"); // TODO: Allow others to play?        
        uif = new UISpriteFactory(Texture.fromBitmapData(Assets.getBitmapData("assets/img/UI.png")));
        
        init();

        
        FFLog.recordMenuStart();

        // TODO: This is so badly hardcoded
        screenController.levelModifiers = new MenuLevelModifiers();
        var initialWeapons:Array<WeaponData> = WeaponGenerator.generateInitialWeapons();
        screenController.levelModifiers.characterWeapons = [
            initialWeapons[0],
            initialWeapons[1],
            initialWeapons[0],
            initialWeapons[1],
            initialWeapons[0], // For testing only
            initialWeapons[2]
        ];
        var weaponParams:WeaponGenParams = new WeaponGenParams();
        weaponParams.evolutionPoints = 100;
        weaponParams.shadynessPoints = 0;
        weaponParams.historicalPoints = 0;
        //bullet
        screenController.levelModifiers.enemyWeapons = [WeaponGenerator.generate(weaponParams)];
        //explosion
        weaponParams.shadynessPoints = 1;
        screenController.levelModifiers.enemyWeapons.push(WeaponGenerator.generate(weaponParams));
        //melee
        weaponParams.shadynessPoints = 3;
        screenController.levelModifiers.enemyWeapons.push(WeaponGenerator.generate(weaponParams));
        screenController.levelModifiers.enemyWeapons.push(WeaponGenerator.generate(weaponParams));
        screenController.levelModifiers.enemyWeapons.push(WeaponGenerator.generate(weaponParams));
    }

    override public function onExit(gameTime:GameTime):Void {
        screenController.removeChild(backGround);
        screenController.removeChild(mainMenu);
        FFLog.recordMenuEnd();
    }

    override public function update(gameTime:GameTime):Void {
        // Cristian Camera Code ~please work
        var levelWidth:Float = 1920;
        var levelHeight:Float = 1080;
        var cameraHalfWidth = screenController.stage.stageWidth / (2 * cameraScale);
        var cameraHalfHeight = screenController.stage.stageHeight / (2 * cameraScale);
        
        // Center camera on player and constrict to level bounds
        var targetX:Float = (1.0 - CAMERA_LERP_SPEED) * cameraX + CAMERA_LERP_SPEED * origin.x;
        var targetY:Float = (1.0 - CAMERA_LERP_SPEED) * cameraY + CAMERA_LERP_SPEED * origin.y;
        cameraX = targetX;
        cameraY = targetY;
    }

    override public function draw(gameTime:GameTime):Void {
        // Empty
    }

    public function init():Void {
        
        camera.addChild(origin);
        
        // Default camera
        cameraX = 0;
        cameraY = 0;
        cameraScale = 32;
        
        screenController.addChild(camera);
        screenController.addChild(origin);
        
        initPanes();
    }
    
    /* The main menu is separate from the background. The init function adds the background
     * to the stae and creates the mainMenuPane, which has homePane, levelSelectPane, and
     * loadoutPane as children */
    private function initPanes():Void {
        //Add the background
        backGround = new Image(Texture.fromBitmapData(Assets.getBitmapData("assets/img/Menu Background.png")));
        screenController.addChild(backGround);
        
        //INIT HOME PANE
        //Set up formatting stuff
        var mainBTF:ButtonTextFormat = {
            tx:150,
            ty:50,
            font:"Verdana",
            size:20,
            color:0x0,
            bold:false,
            hAlign:HAlign.CENTER,
            vAlign:VAlign.CENTER
        };

        //Create Button and position it
        var playButton = uif.createButton(150, 50, "PLAY", mainBTF, false);
        var tutorialButton = uif.createButton(150, 50, "TUTORIAL", mainBTF, false);
        var shopButton = uif.createButton(150, 50, "SHOP", mainBTF, false);
        var levelEditorButton = uif.createButton(150, 50, "LEVEL EDITOR", mainBTF, false);

        //Add button functions
        playButton.bEvent.add(transitionToLevelSelect);
        levelEditorButton.bEvent.add(function():Void {
            var bg = screenController.getChildByName("backGround");
            screenController.removeChild(bg);
            screenController.switchToScreen(3);
        });
        
        //Initialize UIPane and add buttons
        homePane = new UIPane();

        //Horizontal Button Layout
        homePane.add(playButton, 28, 410 - playButton.height);
        homePane.add(tutorialButton, 56 + tutorialButton.width, 410 - playButton.height);
        homePane.add(shopButton, 84 + 2 * shopButton.width, 410 - playButton.height);
        homePane.add(levelEditorButton, 112 + 3 * levelEditorButton.width, 410 - playButton.height);
        
        //Vertical Button Layout 
        /*
        homePane.add(playButton, 400 + 2*playButton.width / 3, 60);
        homePane.add(tutorialButton, 400 + 2*playButton.width / 3, 70 + tutorialButton.height);
        homePane.add(shopButton, 400 + 2*playButton.width / 3, 90 + 2 * shopButton.height);
        homePane.add(levelEditorButton, 400 + 2 * playButton.width / 3, 100 + 3 * shopButton.height);
        */
                
        //INIT LEVEL SELECT PANE
        levelSelectPane = new LevelSelectPane();
        levelSelectPane.menuButton.bEvent.add(transitionToHome);
        levelSelectPane.confirmButton.bEvent.add(transitionToLoadout);
        
        //INIT LOADOUT PANE
        loadoutPane = new LoadoutPane();
        
        //Set up formatting stuff
        var loadoutBTF:ButtonTextFormat = {
            tx:100,
            ty:35,
            font:"Verdana",
            size:20,
            color:0x0,
            bold:false,
            hAlign:HAlign.CENTER,
            vAlign:VAlign.CENTER
        };

        //Create confirm button and add functionality
        confirmButton = uif.createButton(100, 35, "CONFIRM", loadoutBTF, false);
        confirmButton.bEvent.add(startLevel);
        
        loadoutPane.add(confirmButton, 400 - confirmButton.width / 2, 375);
        

        
        mainMenu = new UIPane();
        mainMenu.add(homePane, 0, 0);
        mainMenu.add(levelSelectPane, 1000, 125);
        mainMenu.add(loadoutPane, 1000, 600);
        
        screenController.addChild(mainMenu);
    }
    
    //TODO
    //Transitions the screen to a rectangle and zooms appropriately
    public function transitionTo(min:Point, max:Point) {
        
    }
    
    private function transitionToHome():Void {
        backGround.transformationMatrix.translate(1000, 125);
        mainMenu.transformationMatrix.translate(1000, 125);
    }

    private function transitionToLevelSelect():Void {
        //backGround.transformationMatrix.translate(-1000, -125);
        //mainMenu.transformationMatrix.translate(-1000, -125);
        var timer = 100;
        while (timer > 0) {
            origin.x += 10;
            origin.y += 1.25;
            timer--;
        }
    }

    private function transitionToLoadout():Void {
        backGround.transformationMatrix.translate(0, -475);
        mainMenu.transformationMatrix.translate(0, -475);
    }
    
    //TODO change to BroadcastEvent1 with a string argument for level
    private function startLevel():Void {
        switch levelSelectPane.selectedLevel {
            case 0:
                screenController.loadedLevel = LevelCreator.loadLevelFromFile("assets/level/test.lvl");
                screenController.switchToScreen(2);
            default:
        }
    }
}
