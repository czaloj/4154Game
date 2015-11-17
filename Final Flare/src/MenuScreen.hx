package;

import game.GameLevel;
import game.MenuLevelModifiers;
import haxe.Unserializer;
import openfl.events.Event;
import flash.net.FileReference;
import flash.utils.ByteArray;
import starling.display.Image;
import ui.Checkbox;
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
    //Level select 
    private static var MAX_LEVEL:Int = 0;
    private var selectedLevel:Int = 0;
    
    //Booleans for screen transitions
    private var backGround:Image;  //Background
    
    private var play:Bool = false;
    private var tutorial:Bool = false;
    private var options:Bool = false;
    
    //Buttons
    private var levelButtonArray:Array<Button> = new Array<Button>();
    private var playButton:Button;
    private var tutorialButton:Button;
    private var loadoutButton:Button;
    private var shopButton:Button;
    private var levelEditorButton:Button;
    private var nextButton:Button;
    private var prevButton:Button;
    private var levelButton:Button;
    private var menuButton:Button;
    private var confirmButton:Button;
    
    //Squad select pane
    //There will be many buttons and sprites
    private var charButton1:Button;
    private var charButton2:Button;
    private var charButton3:Button;
    private var charButton4:Button;
    private var charButton5:Button;
    private var prevWeaponButton1:Button;
    private var prevWeaponButton2:Button;
    private var prevWeaponButton3:Button;
    private var prevWeaponButton4:Button;
    private var prevWeaponButton5:Button;
    private var nextWeaponButton1:Button;
    private var nextWeaponButton2:Button;
    private var nextWeaponButton3:Button;
    private var nextWeaponButton4:Button;
    private var nextWeaponButton5:Button;
    private var charWeaponSprite1:Sprite;
    private var charWeaponSprite2:Sprite;
    private var charWeaponSprite3:Sprite;
    private var charWeaponSprite4:Sprite;
    private var charWeaponSprite5:Sprite;
    
    private var firstSelectedSprite:Sprite;
    private var secondSelectedSprite:Sprite;
    private var thirdSelectedSprite:Sprite;
    
    //Weapon select stuff
    private var numSelected:Int = 0;
    
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
        backGround = new Image(Texture.fromBitmapData(Assets.getBitmapData("assets/img/testBack.png")));
        screenController.addChild(backGround);
        
        
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
            null, // For testing only
            initialWeapons[2]
        ];
        var weaponParams:WeaponGenParams = new WeaponGenParams();
        weaponParams.evolutionPoints = 100;
        weaponParams.shadynessPoints = 0;
        weaponParams.historicalPoints = 0;
        screenController.levelModifiers.enemyWeapons = [
            WeaponGenerator.generate(weaponParams),
            WeaponGenerator.generate(weaponParams),
            WeaponGenerator.generate(weaponParams),
            WeaponGenerator.generate(weaponParams),
            WeaponGenerator.generate(weaponParams),
        ];
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
    
    private function initMainMenu():Void {
        //Create button from UISpriteFactory
        var uif:UISpriteFactory = new UISpriteFactory(Texture.fromBitmapData(Assets.getBitmapData("assets/img/UI.png")));
        
        //Set up formatting stuff
        var btf:ButtonTextFormat = {
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
        playButton = uif.createButton(150, 50, "PLAY", btf, false);
        tutorialButton = uif.createButton(150, 50, "TUTORIAL", btf, false);
        shopButton = uif.createButton(150, 50, "SHOP", btf, false);
        levelEditorButton = uif.createButton(150, 50, "LEVEL EDITOR", btf, false);
        
        //Vertical Layout
        //playButton.transformationMatrix.translate(400 + 2*playButton.width / 3, 60);
        //tutorialButton.transformationMatrix.translate(400 + 2*playButton.width / 3, 70 + tutorialButton.height);
        //loadoutButton.transformationMatrix.translate(400 + 2*playButton.width / 3, 80 + 2 * shopButton.height);
        //shopButton.transformationMatrix.translate(400 + 2*playButton.width / 3, 90 + 3 * shopButton.height);
        //levelEditorButton.transformationMatrix.translate(400 + 2*playButton.width / 3, 100 + 4 * shopButton.height);
        
        //Horizontal Layout
        playButton.transformationMatrix.translate(28, 410 - playButton.height);
        tutorialButton.transformationMatrix.translate(56 + tutorialButton.width, 410 - playButton.height);
        shopButton.transformationMatrix.translate(84 + 2* shopButton.width, 410 - playButton.height);
        levelEditorButton.transformationMatrix.translate(112 + 3 * levelEditorButton.width, 410 - playButton.height);
        
        //Add buttons to screen
        screenController.addChild(playButton);
        screenController.addChild(tutorialButton);
        screenController.addChild(shopButton);
        screenController.addChild(levelEditorButton);
        
        //Add button functions
        playButton.bEvent.add(initLevelSelect);
        levelEditorButton.bEvent.add(function():Void {
            exitMainMenu();
            var bg = screenController.getChildByName("backGround");
            screenController.removeChild(bg);
            screenController.switchToScreen(3);
        });
    }
    
    private function exitMainMenu():Void {
        screenController.removeChild(playButton);
        screenController.removeChild(tutorialButton);
        screenController.removeChild(shopButton);
        screenController.removeChild(levelEditorButton);
    }
    
    private function initLevelSelect():Void 
    {
        
        //Remove existing buttons
        exitMainMenu();
        selectedLevel = 0;
        
        //Create button from UISpriteFactory
        var uif:UISpriteFactory = new UISpriteFactory(Texture.fromBitmapData(Assets.getBitmapData("assets/img/UI.png")));
        
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
        
        initLevelButtonArray(uif, btf);
        
        //TODO make custon btf for each button if necessary
        prevButton = uif.createButton(100, 35, "BACK", btf, false);
        nextButton = uif.createButton(100, 35, "NEXT", btf, false);
        menuButton = uif.createButton(100, 35, "MAIN MENU", btf, false);
        confirmButton = uif.createButton(100, 35, "CONFIRM", btf, false);        
        levelButton = levelButtonArray[selectedLevel];
    
        //Translations
        prevButton.transformationMatrix.translate(400 - levelButton.width / 2, 375);
        nextButton.transformationMatrix.translate(400 - levelButton.width / 2 + levelButton.width - nextButton.width, 375);
        confirmButton.transformationMatrix.translate(400 - confirmButton.width / 2, 375);
        menuButton.transformationMatrix.translate(25, 25);
        
        //Add buttons to screen
        screenController.addChild(prevButton);
        screenController.addChild(nextButton);
        screenController.addChild(levelButton);
        screenController.addChild(menuButton);
        screenController.addChild(confirmButton);
        
        //Add functions to event subscribers lists
        prevButton.bEvent.add(decrementLevel);
        prevButton.bEvent.add(updateLevelButton);
        nextButton.bEvent.add(incrementLevel);
        nextButton.bEvent.add(updateLevelButton);
        menuButton.bEvent.add(exitLevelSelect);
        menuButton.bEvent.add(initMainMenu);
        confirmButton.bEvent.add(initSquadSelect);
    }
    
    private function exitLevelSelect():Void {
        screenController.removeChild(prevButton);
        screenController.removeChild(nextButton);
        screenController.removeChild(levelButton);
        screenController.removeChild(menuButton);
        screenController.removeChild(confirmButton);
        //TODO MAYBE clear the levelButton array, idk
    }
    
    private function initSquadSelect():Void {
        exitLevelSelect();
        
        //Create buttons from UISpriteFactory
        var uif:UISpriteFactory = new UISpriteFactory(Texture.fromBitmapData(Assets.getBitmapData("assets/img/UI.png")));
        
        //Set up formatting stuff
        var btf:ButtonTextFormat = {
            tx:60,
            ty:120,
            font:"Verdana", 
            size:20, 
            color:0x0, 
            bold:false, 
            hAlign:HAlign.CENTER, 
            vAlign:VAlign.CENTER
        };
        
        //Set up formatting stuff
        var btf1:ButtonTextFormat = {
            tx:100,
            ty:35,
            font:"Verdana", 
            size:20, 
            color:0x0, 
            bold:false, 
            hAlign:HAlign.CENTER, 
            vAlign:VAlign.CENTER
        };
        
        //Set up formatting stuff
        var btf2:ButtonTextFormat = {
            tx:0,
            ty:0,
            font:"Verdana", 
            size:20, 
            color:0x0, 
            bold:false, 
            hAlign:HAlign.CENTER, 
            vAlign:VAlign.CENTER
        };
        
        //TODO make custon btf for each button if necessary
        //TODO turn into loop once there is an array of all characters
        
        //Create buttons
        charButton1 = uif.createButton(60, 120, "1", btf, true);
        charButton2 = uif.createButton(60, 120, "2", btf, true);
        charButton3 = uif.createButton(60, 120, "3", btf, true);
        charButton4 = uif.createButton(60, 120, "4", btf, true);
        charButton5 = uif.createButton(60, 120, "5", btf, true);
        prevWeaponButton1 = uif.createButton(8, 4, "", btf2, false);
        prevWeaponButton2 = uif.createButton(8, 4, "", btf2, false);
        prevWeaponButton3 = uif.createButton(8, 4, "", btf2, false);
        prevWeaponButton4 = uif.createButton(8, 4, "", btf2, false);
        prevWeaponButton5 = uif.createButton(8, 4, "", btf2, false);
        nextWeaponButton1 = uif.createButton(8, 4, "", btf2, false);
        nextWeaponButton2 = uif.createButton(8, 4, "", btf2, false);
        nextWeaponButton3 = uif.createButton(8, 4, "", btf2, false);
        nextWeaponButton4 = uif.createButton(8, 4, "", btf2, false);
        nextWeaponButton5 = uif.createButton(8, 4, "", btf2, false);
        confirmButton = uif.createButton(100, 35, "CONFIRM", btf1, false);   
       
        //Button translations
        charButton1.transformationMatrix.translate(62.5 + 0, 50);
        charButton2.transformationMatrix.translate(62.5 + 75 + charButton2.width, 50);
        charButton3.transformationMatrix.translate(62.5 + 150 + 2 * charButton3.width, 50);
        charButton4.transformationMatrix.translate(62.5 + 225 + 3* charButton4.width, 50);
        charButton5.transformationMatrix.translate(62.5 + 300 + 4 * charButton5.width, 50);
        prevWeaponButton1.transformationMatrix.translate(charButton1.bounds.x - prevWeaponButton1.width - 8, charButton1.bounds.y + charButton1.height + 8);
        prevWeaponButton2.transformationMatrix.translate(charButton2.bounds.x - prevWeaponButton2.width - 8, charButton2.bounds.y + charButton1.height + 8);
        prevWeaponButton3.transformationMatrix.translate(charButton3.bounds.x - prevWeaponButton3.width - 8, charButton3.bounds.y + charButton1.height + 8);
        prevWeaponButton4.transformationMatrix.translate(charButton4.bounds.x - prevWeaponButton4.width - 8, charButton4.bounds.y + charButton1.height + 8);
        prevWeaponButton5.transformationMatrix.translate(charButton5.bounds.x - prevWeaponButton5.width - 8, charButton5.bounds.y + charButton1.height + 8);
        nextWeaponButton1.transformationMatrix.translate(charButton1.bounds.x + charButton1.width + 8, charButton1.bounds.y + charButton1.height + 8);
        nextWeaponButton2.transformationMatrix.translate(charButton2.bounds.x + charButton2.width + 8, charButton2.bounds.y + charButton2.height + 8);
        nextWeaponButton3.transformationMatrix.translate(charButton3.bounds.x + charButton3.width + 8, charButton3.bounds.y + charButton3.height + 8);
        nextWeaponButton4.transformationMatrix.translate(charButton4.bounds.x + charButton4.width + 8, charButton4.bounds.y + charButton4.height + 8);
        nextWeaponButton5.transformationMatrix.translate(charButton5.bounds.x + charButton5.width + 8, charButton5.bounds.y + charButton5.height + 8);
        confirmButton.transformationMatrix.translate(400 - confirmButton.width / 2, 375);
        
        //Add buttons to screen
        screenController.addChild(charButton1);
        screenController.addChild(charButton2);
        screenController.addChild(charButton3);
        screenController.addChild(charButton4);
        screenController.addChild(charButton5);
        screenController.addChild(prevWeaponButton1);
        screenController.addChild(prevWeaponButton2);
        screenController.addChild(prevWeaponButton3);
        screenController.addChild(prevWeaponButton4);
        screenController.addChild(prevWeaponButton5);
        screenController.addChild(nextWeaponButton1);
        screenController.addChild(nextWeaponButton2);
        screenController.addChild(nextWeaponButton3);
        screenController.addChild(nextWeaponButton4);
        screenController.addChild(nextWeaponButton5);
        screenController.addChild(confirmButton);
        
        //Add button functions
        
        confirmButton.bEvent.add(startLevel);
        
    }
    
    
    //Initialize the array of level buttons (one for each level)
    private function initLevelButtonArray(uif:UISpriteFactory, btf:ButtonTextFormat):Void {
        var i:Int = 0;
        while (i <= MAX_LEVEL) {
            var button = uif.createButton(450, 225, "LEVEL " + (i + 1) , btf, false);
            button.transformationMatrix.translate(400 - button.width / 2, 200 - button.height / 2);
            levelButtonArray.push(button);
            i++;
        }
    }
    
    private function updateLevelButton():Void {
        screenController.removeChild(levelButton);
        levelButton = levelButtonArray[selectedLevel];
        screenController.addChild(levelButton);        
    }
    
    private function changeLevel(delta:Int):Void {
        selectedLevel += delta;
        if (selectedLevel < 0) { selectedLevel = 0; }
        if (selectedLevel > MAX_LEVEL) { selectedLevel = MAX_LEVEL; }
    }
    
    private function decrementLevel():Void {
        changeLevel(-1);
    }
    
    private function incrementLevel():Void {
        changeLevel(1);
    }    
    
    //TODO change to BroadcastEvent1 with a string argument for level
    private function startLevel():Void {
        switch selectedLevel {
            case 0: 
                screenController.loadedLevel = LevelCreator.loadLevelFromFile("assets/level/test.lvl");
                //Move these outside switch when all levels are made
                exitLevelSelect();
                screenController.switchToScreen(2);
            default:
        }
    }
    
    //Dead function 
    private function checkButtonStates():Void {
        
        if (playButton.clicked) { play = true; }
        else { play = false; }
        if (tutorialButton.clicked) { tutorial = true; }
        else { tutorial = false; }
        if (shopButton.clicked = true) { options = true; }
        else { options = false; }        
    }
}
