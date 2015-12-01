package;

import game.GameLevel;
import game.MenuLevelModifiers;
import haxe.Unserializer;
import openfl.events.Event;
import flash.net.FileReference;
import flash.utils.ByteArray;
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
    
    //UIPanes    
    private var mainMenuPane:UIPane; //This didn't need any special functionality so it's a generic pane
    private var levelSelectPane:LevelSelectPane;
    private var loadoutPane:LoadoutPane;

    private var uif:UISpriteFactory;  //Buttons are created from UISpriteFactory    
    private var backGround:Image;     //Background
    private var confirmButton:Button; //For squad select pane
    
    private var selectedLevel:Int;

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
        selectedLevel = 0;
        uif = new UISpriteFactory(Texture.fromBitmapData(Assets.getBitmapData("assets/img/UI.png")));
        initPanes();
        initMainMenu();
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
        FFLog.recordMenuEnd();
    }

    override public function update(gameTime:GameTime):Void {
        // Empty
    }

    override public function draw(gameTime:GameTime):Void {
        // Empty
    }

    private function initPanes():Void {
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
        playButton.bEvent.add(initLevelSelect);
        levelEditorButton.bEvent.add(function():Void {
            exitMainMenu();
            var bg = screenController.getChildByName("backGround");
            screenController.removeChild(bg);
            screenController.switchToScreen(3);
        });
        
        //Initialize UIPane and add buttons
        mainMenuPane = new UIPane();

        //Horizontal Button Layout
        mainMenuPane.add(playButton, 28, 410 - playButton.height);
        mainMenuPane.add(tutorialButton, 56 + tutorialButton.width, 410 - playButton.height);
        mainMenuPane.add(shopButton, 84 + 2 * shopButton.width, 410 - playButton.height);
        mainMenuPane.add(levelEditorButton, 112 + 3 * levelEditorButton.width, 410 - playButton.height);
        
        //Vertical Button Layout 
        /*
        mainPane.add(playButton, 400 + 2*playButton.width / 3, 60);
        mainPane.add(tutorialButton, 400 + 2*playButton.width / 3, 70 + tutorialButton.height);
        mainPane.add(shopButton, 400 + 2*playButton.width / 3, 90 + 2 * shopButton.height);
        mainPane.add(levelEditorButton, 400 + 2 * playButton.width / 3, 100 + 3 * shopButton.height);
        */
                
        //Initialize UIPane
        levelSelectPane = new LevelSelectPane();
        levelSelectPane.menuButton.bEvent.add(exitLevelSelect);
        levelSelectPane.menuButton.bEvent.add(initMainMenu);
        levelSelectPane.confirmButton.bEvent.add(initLoadoutScreen);
        screenController.addChild(levelSelectPane);
        
        //Create Pane
        loadoutPane = new LoadoutPane();
    }
    
    private function initMainMenu():Void {
        backGround = new Image(Texture.fromBitmapData(Assets.getBitmapData("assets/img/TitleScreen.png")));
        screenController.addChild(backGround);
        screenController.addChild(mainMenuPane);
    }

    private function exitMainMenu():Void {
        screenController.removeChild(mainMenuPane);
        screenController.removeChild(backGround);
    }

    private function initLevelSelect():Void
    {
        exitMainMenu();
        backGround = new Image(Texture.fromBitmapData(Assets.getBitmapData("assets/img/testBack.png")));
        screenController.addChild(backGround);
        screenController.addChild(levelSelectPane);
    }

    private function exitLevelSelect():Void {
        screenController.removeChild(levelSelectPane);
        //TODO MAYBE clear the levelButton array, idk
    }

    private function initLoadoutScreen():Void {
        exitLevelSelect();

        backGround = new Image(Texture.fromBitmapData(Assets.getBitmapData("assets/img/testBack.png")));
        screenController.addChild(backGround);

        //Set up formatting stuff
        var btf:ButtonTextFormat = {
            tx:100,
            ty:35,
            font:"Verdana",
            size:20,
            color:0x0,
            bold:false,
            hAlign:HAlign.CENTER,
            vAlign:VAlign.CENTER
        };

        //Create UI elements
        confirmButton = uif.createButton(100, 35, "CONFIRM", btf, false);
        confirmButton.transformationMatrix.translate(400 - confirmButton.width / 2, 375);

        //Add pane to stage
        screenController.addChild(loadoutPane);
        screenController.addChild(confirmButton);
        
        //Add button functions        
        confirmButton.bEvent.add(startLevel);
    }
    
    private function exitLoadoutScreen():Void {
        screenController.removeChild(loadoutPane);
        screenController.removeChild(confirmButton);
    }

    
    //TODO change to BroadcastEvent1 with a string argument for level
    private function startLevel():Void {
        switch selectedLevel {
            case 0:
                screenController.loadedLevel = LevelCreator.loadLevelFromFile("assets/level/test.lvl");
                //Move these outside switch when all levels are made
                exitLoadoutScreen();
                screenController.switchToScreen(2);
            default:
        }
    }
}
