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
    public static inline var LERP_SPEED:Float = .02;
    public static var ZERO:Point = new Point(0, 0);
    
    public static var HOME_POS:Point = new Point(0, 0);
    public static var LEVEL_SELECT_POS = new Point(1000, 125);
    public static var LOADOUT_POS = new Point(1000, 600);
    public static var SHOP_POS:Point = new Point(0, 600);
    
    //Current position of camera
    public var currentMin:Point = new Point();
    public var currentMax:Point = new Point();
    
    //Distance to translate each frame
    public var delta:Point = new Point();
    
    //Total distance to translate before transistionDone is marked as true
    public var distance:Point = new Point();
    public var transitionDone:Bool = true;
    
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
    
    override public function build():Void {
        // Empty
    }
    override public function destroy():Void {
        // Empty
    }

    override public function onEntry(gameTime:GameTime):Void {
        screenController.playerData = new PlayerData("Player"); // TODO: Allow others to play?        
        uif = new UISpriteFactory(Texture.fromBitmapData(Assets.getBitmapData("assets/img/UI.png")));
        
        currentMin.setTo(0, 0);
        currentMax.setTo(800, 450);
        
        initPanes();

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
        updateCamera();

    }

    override public function draw(gameTime:GameTime):Void {
        // Empty
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
        mainMenu.add(homePane, HOME_POS.x, HOME_POS.y);
        mainMenu.add(levelSelectPane, LEVEL_SELECT_POS.x, LEVEL_SELECT_POS.y);
        mainMenu.add(loadoutPane, LOADOUT_POS.x, LOADOUT_POS.y);
        
        screenController.addChild(mainMenu);
    }
    
    //TODO
    //Transitions the screen to a rectangle and zooms appropriately
    public function transitionToRect(min:Point/*, max:Point*/) {
           distance = min.subtract(currentMin);
           delta.setTo(( -distance.x * LERP_SPEED), -distance.y * LERP_SPEED);
           currentMin = min;
           transitionDone = false;
    }
    
    public function updateCamera():Void {
        if (!transitionDone) {
            mainMenu.transformationMatrix.translate(delta.x, delta.y);
            backGround.transformationMatrix.translate(delta.x, delta.y);
            distance = distance.add(delta);
            if (distance.equals(ZERO)) { 
                transitionDone = true;
            }            
        }
    }
    
    private function transitionToHome():Void {
        transitionToRect(HOME_POS);
    }

    private function transitionToLevelSelect():Void {
        transitionToRect(LEVEL_SELECT_POS);
    }

    private function transitionToLoadout():Void {
        transitionToRect(LOADOUT_POS);
    }
    
    //TODO change to BroadcastEvent1 with a string argument for level
    private function startLevel():Void {
        switch levelSelectPane.selectedLevel {
            case 0:
                screenController.loadedLevel = LevelCreator.loadLevelFromFile("assets/level/easy.lvl");
                screenController.switchToScreen(2);
            default:
        }
    }
}
