package;

import game.GameLevel;
import game.MenuLevelModifiers;
import haxe.Unserializer;
import flash.net.FileReference;
import flash.utils.ByteArray;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.geom.Point;
import openfl.Assets;
import openfl.text.TextField;
import openfl.text.TextFieldAutoSize;
import openfl.text.TextFieldType;
import openfl.text.TextFormat;
import openfl.text.TextFormatAlign;
import ui.ShopElement;
import ui.ShopResult;
import ui.UISpriteFactory;
import ui.Button;
import ui.Button.ButtonTextFormat;
import ui.UIPane;
import ui.LevelSelectPane;
import ui.LoadoutPane;
import ui.UICharacter;
import weapon.WeaponData;
import weapon.Weapon;
import weapon.WeaponGenParams;
import weapon.WeaponLayer;
import weapon.WeaponGenerator;
import starling.display.Image;
import starling.textures.Texture;
import starling.utils.HAlign;
import starling.utils.VAlign;
import starling.text.TextField;

class MenuScreen extends IGameScreen {
    public static inline var LERP_SPEED:Float = .02;
    public static var ZERO:Point = new Point(0, 0);

    public static var HOME_POS_MIN:Point = new Point(30, 609);
    public static var HOME_POS_MAX:Point = new Point(829, 1058);
    public static var LEVEL_SELECT_POS_MIN:Point = new Point(22, 17);
    public static var LEVEL_SELECT_POS_MAX:Point = new Point(956, 542);
    public static var LOADOUT_POS_MIN:Point = new Point(1045, 163);
    public static var LOADOUT_POS_MAX:Point = new Point(1844, 612);
    public static var TEMP_MIN:Point = new Point(880, 629);
    public static var TEMP_MAX:Point = new Point(1680, 1079);
    //public static var SHOP_POS_MIN:Point = new Point(1399, 791);
    //public static var SHOP_POS_MAX:Point = new Point(1874, 1058);


    //Current position of camera
    public var currentMin:Point = new Point();
    public var currentMax:Point = new Point();
    public var currentWindow:Point = new Point();
    public var window:Point = new Point();

    //Distance to translate each frame
    public var delta:Point = new Point();
    public var deltaScale:Point = new Point();

    //Total distance to translate before transistionDone is marked as true
    public var distance:Point = new Point();
    public var transitionDone:Bool = true;

    //UIPanes
    private var mainMenu:UIPane;
    private var homePane:UIPane; //This didn't need any special functionality so it's a generic pane
    private var levelSelectPane:LevelSelectPane;
    private var loadoutPane:LoadoutPane;
    private var shopPane:UIPane;
    private var shopResult:ShopResult;
    private var points:ShopElement;
    private var evolution:ShopElement;
    private var historical:ShopElement;
    private var shadiness:ShopElement;

    private var uif:UISpriteFactory;  //Buttons are created from UISpriteFactory
    private var backGround:Image;     //Background

    private var generateButton:Button; //For squad select pane

    public function new(sc:ScreenController) {
        super(sc);
    }

    override public function build():Void {
        screenController.playerData = new PlayerData("Player"); // TODO: Allow others to play?
    }
    override public function destroy():Void {
        // Empty
    }

    override public function onEntry(gameTime:GameTime):Void {
        uif = new UISpriteFactory(Texture.fromBitmapData(Assets.getBitmapData("assets/img/UI.png")));

        currentMin.setTo(0, 0);
        currentMax.setTo(800, 450);
        delta.setTo(0, 0);
        distance.setTo(0, 0);
        initPanes();
        mainMenu.transformationMatrix.translate(-HOME_POS_MIN.x, -HOME_POS_MIN.y);
        backGround.transformationMatrix.translate( -HOME_POS_MIN.x, -HOME_POS_MIN.y);
        currentMin = HOME_POS_MIN;
        currentMax = HOME_POS_MAX;
        currentWindow.setTo(currentMax.x - currentMin.x, currentMax.y - currentMin.y);

        FFLog.recordMenuStart();

        // TODO: This is so badly hardcoded
        screenController.levelModifiers = new MenuLevelModifiers();
        var initialWeapons:Array<WeaponData> = WeaponGenerator.generateInitialWeapons();
        screenController.levelModifiers.characterWeapons = [
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
        screenController.levelModifiers.enemyWeapons = [WeaponGenerator.generate(weaponParams)];
        weaponParams.evolutionPoints = 1000;
        weaponParams.shadynessPoints = 40;
        screenController.levelModifiers.enemyWeapons.push(WeaponGenerator.generate(weaponParams));
        screenController.levelModifiers.enemyWeapons.push(WeaponGenerator.generate(weaponParams));
        weaponParams.evolutionPoints = 2000;
        weaponParams.shadynessPoints = 100;
        weaponParams.historicalPoints = 80;
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
        if (evolution.allocated < 100) {
            generateButton.enabled = false;
            generateButton.currentState = generateButton.downState;
        }
        else {
            generateButton.enabled = true; 
            generateButton.currentState = generateButton.upState;
        }
    }

    override public function draw(gameTime:GameTime):Void {
        // Empty
    }

    /* The main menu is separate from the background. The init function adds the background
     * to the stae and creates the mainMenuPane, which has homePane, levelSelectPane, and
     * loadoutPane as children */
    private function initPanes():Void {
        //Add the background
        backGround = new Image(Texture.fromBitmapData(Assets.getBitmapData("assets/img/MenuScreens.png")));
        screenController.addChild(backGround);

        //INIT HOME PANE
        //Set up formatting stuff
        var mainBTF:ButtonTextFormat = {
            tx:150,
            ty:50,
            font:"BitFont",
            size:40,
            color:0xFFFFFF,
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
        tutorialButton.bEvent.add(function():Void {
            //screenController.playerData.selectedChars = ["Man", "Wolf", "Robot"];
            screenController.loadedLevel = LevelCreator.loadLevelFromFile("assets/level/tutorial.lvl");
            screenController.switchToScreen(2);
        });
        levelEditorButton.bEvent.add(function():Void {
            var bg = screenController.getChildByName("backGround");
            screenController.removeChild(bg);
            screenController.switchToScreen(3);
        });
        tutorialButton.bEvent.add(function():Void {
            screenController.loadedLevel = LevelCreator.loadLevelFromFile("assets/level/tutorial.lvl");
            screenController.switchToScreen(2);
        });
        shopButton.bEvent.add(transitionToShop);

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
            font:"BitFont",
            size:50,
            color:0xFFFFFF,
            bold:false,
            hAlign:HAlign.CENTER,
            vAlign:VAlign.CENTER
        };

        //Create confirm button and add functionality
        var confirmButton = uif.createButton(100, 35, "CONFIRM", loadoutBTF, false);
        confirmButton.bEvent.add(startLevel);

        loadoutPane.add(confirmButton, 400 - confirmButton.width / 2, 375);

        //INIT SHOP PANE
        shopPane = new UIPane();

        //Set up formatting stuff
        var shopBTF:ButtonTextFormat = {
            tx:200,
            ty:35,
            font:"BitFont",
            size:50,
            color:0xFFFFFF,
            bold:false,
            hAlign:HAlign.CENTER,
            vAlign:VAlign.CENTER
        };

        var btf:ButtonTextFormat = {
            tx:100,
            ty:35,
            font:"BitFont",
            size:50,
            color:0xFFFFFF,
            bold:false,
            hAlign:HAlign.CENTER,
            vAlign:VAlign.CENTER
        };

        //Add UI elements
        evolution = new ui.ShopElement("Evolution Points: ", screenController.playerData.points);
        shadiness = new ui.ShopElement("Shadiness Points: ", 0);
        historical = new ShopElement("Historical Points: ", 0);
        
        //Hard coding button disables because apparantly we don't havee 3 kinds of points
        shadiness.disable();
        historical.disable();

        generateButton = uif.createButton(200, 35, "GENERATE WEAPON", shopBTF, false);
        var menuButton = uif.createButton(100, 35, "MAIN MENU", btf, false);

        menuButton.bEvent.add(transitionToHome);
        generateButton.bEvent.add(generateWeapon);
        
        shopPane.add(evolution, 400 - evolution.width/2, 120);
        shopPane.add(shadiness, 400 - shadiness.width/2, 205);
        shopPane.add(historical, 400 - historical.width / 2, 280);
        shopPane.add(generateButton, 400 - generateButton.width / 2, 375);
        shopPane.add(menuButton, 25, 25);

        mainMenu = new UIPane();
        mainMenu.add(homePane, HOME_POS_MIN.x, HOME_POS_MIN.y);
        mainMenu.add(levelSelectPane, LEVEL_SELECT_POS_MIN.x, LEVEL_SELECT_POS_MIN.y);
        mainMenu.add(loadoutPane, LOADOUT_POS_MIN.x, LOADOUT_POS_MIN.y);
        mainMenu.add(shopPane, TEMP_MIN.x, TEMP_MIN.y);

        screenController.addChild(mainMenu);

    }

    //TODO
    //Transitions the screen to a rectangle and zooms appropriately
    public function transitionToRect(min:Point, max:Point) {
        distance = min.subtract(currentMin);
        delta.setTo(( -distance.x * LERP_SPEED), ( -distance.y * LERP_SPEED));
        currentWindow.setTo(currentMax.x - currentMin.x, currentMax.y - currentMin.y);
        window.setTo(max.x - min.x, max.y - min.y);
        deltaScale.setTo(currentWindow.x / window.x, currentWindow.y / window.y);


        currentMin = min;
        currentMax = max;

        transitionDone = false;
    }

    public function updateCamera():Void {
        if (!transitionDone) {
            mainMenu.transformationMatrix.translate(delta.x, delta.y);
            backGround.transformationMatrix.translate(delta.x, delta.y);
            distance = distance.add(delta);
            if (Math.abs(distance.x) < .2 || Math.abs(distance.y) < .2) {
                //backGround.transformationMatrix.scale(deltaScale.x, deltaScale.y);
                mainMenu.transformationMatrix.translate( -distance.x, -distance.y);
                backGround.transformationMatrix.translate( -distance.x, -distance.y);
                transitionDone = true;

            }
        }
    }

    private function createInputTextField(height:Float, width:Float, x:Float = 0, y:Float = 0, font:String, fontSize:Float, fontColor:UInt, bg:Bool, bgColor:UInt = null):Sprite {
        var sprite:Sprite = new Sprite();

        // Create default text format
        var textFormat:TextFormat = new TextFormat(font, fontSize, fontColor);
        textFormat.align = TextFormatAlign.CENTER;

        // Create default text format
        var tf = new openfl.text.TextField();
        tf.height = height;
        tf.width = width;
        tf.x = x;
        tf.y = y;
        tf.defaultTextFormat = textFormat;
        tf.type = TextFieldType.INPUT;
        tf.background = bg;
        tf.backgroundColor = bgColor;
        sprite.addChild(tf);
        return sprite;
    }

    private function transitionToHome():Void {
        transitionToRect(HOME_POS_MIN.clone(), HOME_POS_MAX.clone());
    }

    private function transitionToLevelSelect():Void {
        transitionToRect(LEVEL_SELECT_POS_MIN.clone(), LEVEL_SELECT_POS_MAX.clone());
    }

    private function transitionToLoadout():Void {
        transitionToRect(LOADOUT_POS_MIN.clone(), LOADOUT_POS_MAX.clone());
    }

    private function transitionToShop():Void {
        transitionToRect(TEMP_MIN.clone(), TEMP_MAX.clone());
    }

    //TODO change to BroadcastEvent1 with a string argument for level
    private function startLevel():Void {
        var i = 0;
        while (i < loadoutPane.selected.length) {
            screenController.playerData.selectedChars.push((loadoutPane.selected[i]));
            i++;
        }

        switch levelSelectPane.selectedLevel {
            case 0:
                screenController.loadedLevel = LevelCreator.loadLevelFromFile("assets/level/test.lvl");
            case 1:
                screenController.loadedLevel = LevelCreator.loadLevelFromFile("assets/level/caged4.lvl");
            case 2:
                screenController.loadedLevel = LevelCreator.loadLevelFromFile("assets/level/easy.lvl");
            case 3:
                screenController.loadedLevel = LevelCreator.loadLevelFromFile("assets/level/medium.lvl");
            default:
        }
        screenController.switchToScreen(2);
    }

    
    public function generateWeapon() {
        var p  = evolution.allocated;
        var dif = (screenController.playerData.points - p);
        screenController.playerData.points -= p;
        if (p >= 100 && dif >= 0) {
            generateButton.enabled = false;
            evolution.disable();
            
            var params:WeaponGenParams = new WeaponGenParams();
            params.evolutionPoints = p;
            var data = WeaponGenerator.generate(params);
            var weaponSprite = WeaponGenerator.buildSprite(data, Assets.getBitmapData("assets/img/Guns.png"));
            weaponSprite.scaleX *= 32 * 5;
            weaponSprite.scaleY *= -32 * 5;
            shopResult = new ShopResult(weaponSprite);
            shopResult.button.bEvent.add(function():Void {
                shopPane.removeChild(shopResult);
                evolution.enable();
                generateButton.enabled = true;
                
            });
            screenController.playerData.weapons.push(data);
            shopPane.add(shopResult, 400 - shopResult.width / 2, 225 - shopResult.height / 2);
            evolution.allocate( -p);
            evolution.maxAlloc = evolution.maxAlloc - p;
        }
    }
}
