package;

import game.GameLevel;
import game.MenuLevelModifiers;
import haxe.Unserializer;
import openfl.events.Event;
import flash.net.FileReference;
import flash.utils.ByteArray;
import starling.display.Image;
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
    
    //Buttons are created from UISpriteFactory
    private var uif:UISpriteFactory;
    
    //UIPanes    
    private var mainMenuPane:UIPane;
    private var levelSelectPane:LevelSelectPane;
    private var charSelectPane:UIPane;
    
    //Level select

    private var selectedLevel:Int = 0;

    //Background
    private var backGround:Image;  

    //Squad select pane
    //There will be many buttons and sprites
    private var confirmButton:Button;
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
    private var charButtonArray:Array<Button>;    
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
        screenController.playerData = new PlayerData("Player"); // TODO: Allow others to play?
                
        uif = new UISpriteFactory(Texture.fromBitmapData(Assets.getBitmapData("assets/img/UI.png")));
        
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

    private function initMainMenu():Void {
        backGround = new Image(Texture.fromBitmapData(Assets.getBitmapData("assets/img/TitleScreen.png")));
        screenController.addChild(backGround);

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
        var playButton = uif.createButton(150, 50, "PLAY", btf, false);
        var tutorialButton = uif.createButton(150, 50, "TUTORIAL", btf, false);
        var shopButton = uif.createButton(150, 50, "SHOP", btf, false);
        var levelEditorButton = uif.createButton(150, 50, "LEVEL EDITOR", btf, false);

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
        
        //Initialize UIPane
        levelSelectPane = new LevelSelectPane();
        levelSelectPane.menuButton.bEvent.add(exitLevelSelect);
        levelSelectPane.menuButton.bEvent.add(initMainMenu);
        levelSelectPane.confirmButton.bEvent.add(initSquadSelect);
        screenController.addChild(levelSelectPane);
    }

    private function exitLevelSelect():Void {
        screenController.removeChild(levelSelectPane);
        //TODO MAYBE clear the levelButton array, idk
    }

    private function initSquadSelect():Void {
        exitLevelSelect();

        backGround = new Image(Texture.fromBitmapData(Assets.getBitmapData("assets/img/testBack.png")));
        screenController.addChild(backGround);
        
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
        charButton1 = uif.createButton(59, 119, "1", btf, true);
        charButton2 = uif.createButton(59, 119, "2", btf, true);
        charButton3 = uif.createButton(59, 119, "3", btf, true);
        charButton4 = uif.createButton(59, 119, "4", btf, true);
        charButton5 = uif.createButton(59, 119, "5", btf, true);
        prevWeaponButton1 = uif.createButton(4, 0, "", btf2, false);
        prevWeaponButton2 = uif.createButton(4, 0, "", btf2, false);
        prevWeaponButton3 = uif.createButton(4, 0, "", btf2, false);
        prevWeaponButton4 = uif.createButton(4, 0, "", btf2, false);
        prevWeaponButton5 = uif.createButton(4, 0, "", btf2, false);
        nextWeaponButton1 = uif.createButton(4, 0, "", btf2, false);
        nextWeaponButton2 = uif.createButton(4, 0, "", btf2, false);
        nextWeaponButton3 = uif.createButton(4, 0, "", btf2, false);
        nextWeaponButton4 = uif.createButton(4, 0, "", btf2, false);
        nextWeaponButton5 = uif.createButton(4, 0, "", btf2, false);
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
        
        firstSelectedSprite = new Sprite();
        var tf1:TextField = new TextField(30, 30, "1", "Verdana", 20, 0xFFFFFF, true);
        tf1.hAlign = HAlign.CENTER;
        tf1.vAlign = VAlign.CENTER;
        firstSelectedSprite.addChild(tf1);
        
        secondSelectedSprite = new Sprite();
        var tf2:TextField = new TextField(30, 30, "2", "Verdana", 20, 0xFFFFFF, true);
        tf2.hAlign = HAlign.CENTER;
        tf2.vAlign = VAlign.CENTER;
        secondSelectedSprite.addChild(tf2);
        
        thirdSelectedSprite = new Sprite();
        var tf3:TextField = new TextField(30, 30, "3", "Verdana", 20, 0xFFFFFF, true);
        tf3.hAlign = HAlign.CENTER;
        tf3.vAlign = VAlign.CENTER;
        thirdSelectedSprite.addChild(tf3);
        
        charButtonArray = new Array<Button>();
        charButtonArray.push(charButton1);
        charButtonArray.push(charButton2);
        charButtonArray.push(charButton3);
        charButtonArray.push(charButton4);
        charButtonArray.push(charButton5);

        //Add button functions        
        confirmButton.bEvent.add(startLevel);
        charButton1.bEvent1.add(selectChar);
        charButton2.bEvent1.add(selectChar);
        charButton3.bEvent1.add(selectChar);
        charButton4.bEvent1.add(selectChar);
        charButton5.bEvent1.add(selectChar);
        
        trace(charButton1.width);
        trace(charButton1.height);
        trace(charButton2.bounds.y);
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
    
    private function selectChar(b:Button) {
        switch numSelected {
            case 0:
                firstSelectedSprite.transformationMatrix.translate(b.bounds.x + b.width/2 - 15, b.bounds.y - 35);
                screenController.addChild(firstSelectedSprite);
                b.customData = 1;
                numSelected++;
            case 1:
                if (b.customData == 0) {
                    secondSelectedSprite.transformationMatrix.translate(b.bounds.x + b.width/2 - 15, b.bounds.y - 35);
                    screenController.addChild(secondSelectedSprite);
                    b.customData = 2;
                    numSelected++;
                }
                else {
                    adjustCharSelect(b, b.customData);
                }
            case 2:
                if (b.customData == 0) {
                    thirdSelectedSprite.transformationMatrix.translate(b.bounds.x + b.width/2 - 15, b.bounds.y - 30);
                    screenController.addChild(thirdSelectedSprite);
                    b.customData = 3;
                    numSelected++;
                }
                else {
                    adjustCharSelect(b, b.customData);
                }
            case 3:
                if (b.customData != 0) {
                    adjustCharSelect(b, b.customData);
                }
        }
        
        if (numSelected == 3) {
            var b = 0;
            while (b < charButtonArray.length) {
                if (charButtonArray[b].customData == 0) { charButtonArray[b].enabled = false; }
                b++;
            }
        }
    }
    
    //Super hacky way to do char select 
    private function adjustCharSelect(b:Button, i:Int):Void {
        switch numSelected {
            case 1:
                var x1 = firstSelectedSprite.bounds.x;
                var y1 = firstSelectedSprite.bounds.y;
               
                firstSelectedSprite.transformationMatrix.translate( -x1, -y1);
                screenController.removeChild(firstSelectedSprite);
                b.customData = 0;
                
                numSelected--;
                
            case 2:
                var x2 = secondSelectedSprite.bounds.x;
                var y2 = secondSelectedSprite.bounds.y;
                secondSelectedSprite.transformationMatrix.translate( -x2, -y2);
                screenController.removeChild(secondSelectedSprite);
                b.customData = 0;
                numSelected--;

                if (i == 1) {
                    var x1 = firstSelectedSprite.bounds.x;
                    var y1 = firstSelectedSprite.bounds.y;
                    
                    firstSelectedSprite.transformationMatrix.translate( -x1, -y1);                    
                    firstSelectedSprite.transformationMatrix.translate(x2, y2);
                    
                    var b = 0;
                    while (b < charButtonArray.length) {
                        if (charButtonArray[b].customData == 2) { charButtonArray[b].customData = 1; }
                        else {charButtonArray[b].customData = 0; }
                        b++;
                    }
                }
                
            case 3:
                var x3 = thirdSelectedSprite.bounds.x;
                var y3 = thirdSelectedSprite.bounds.y;
                thirdSelectedSprite.transformationMatrix.translate(-x3,-y3);
                screenController.removeChild(thirdSelectedSprite);
                numSelected--; 
                
                b.customData = 0;

                
                if (i == 2) {
                    var x2 = secondSelectedSprite.bounds.x;
                    var y2 = secondSelectedSprite.bounds.y;
                    
                    secondSelectedSprite.transformationMatrix.translate( -x2, -y2);
                    secondSelectedSprite.transformationMatrix.translate(x3, y3);

                    var b = 0;
                    while (b < charButtonArray.length) {
                        if (charButtonArray[b].customData == 3) { 
                            charButtonArray[b].customData = 2; 
                            break;
                        }
                        b++;
                    }
                }
                
                if (i == 1) {
                    var x1 = firstSelectedSprite.bounds.x;
                    var y1 = firstSelectedSprite.bounds.y;                    
                    var x2 = secondSelectedSprite.bounds.x;
                    var y2 = secondSelectedSprite.bounds.y;
                
                    firstSelectedSprite.transformationMatrix.translate( -x1, -y1);
                    firstSelectedSprite.transformationMatrix.translate(x2, y2);  
                    secondSelectedSprite.transformationMatrix.translate( -x2, -y2);                                      
                    secondSelectedSprite.transformationMatrix.translate(x3, y3);
                    
                    var b = 0;
                    while (b < charButtonArray.length) {
                        if (charButtonArray[b].customData == 3) { 
                            charButtonArray[b].customData = 2; 
                        }
                        else if (charButtonArray[b].customData == 2) {
                            charButtonArray[b].customData = 1;
                        }
                        b++;
                    }
                }
                
                var b = 0;
                while (b < charButtonArray.length) {
                    if (!charButtonArray[b].enabled) { charButtonArray[b].enabled = true; }
                    b++;
                }
        }
    }
}
