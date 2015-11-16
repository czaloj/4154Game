package;

import game.GameLevel;
import game.MenuLevelModifiers;
import haxe.Unserializer;
import openfl.events.Event;
import flash.net.FileReference;
import flash.utils.ByteArray;
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
    private static var MAX_LEVEL:Int = 9;
    private var selectedLevel:Int = 0;
    
    //Booleans for screen transitions
    private var play:Bool = false;
    private var tutorial:Bool = false;
    private var options:Bool = false;
    
    
    //Buttons
    private var levelButtonArray:Array<Button> = new Array<Button>();
    private var playButton:Button;
    private var tutorialButton:Button;
    private var optionsButton:Button;
    private var nextButton:Button;
    private var prevButton:Button;
    private var levelButton:Button;
    private var menuButton:Button;
    private var confirmButton:Button;
    
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
        initMainMenu();

        FFLog.recordMenuStart();

        // Begin loading a file
        // TODO: Fully remove soon?
        var fileRef:FileReference = new FileReference();
        fileRef.addEventListener(Event.SELECT, onFileBrowse);
        //fileRef.browse();
        
        // TODO: This is so badly hardcoded
        var mod:MenuLevelModifiers = new MenuLevelModifiers();
        var weaponParams:WeaponGenParams = new WeaponGenParams();
        weaponParams.evolutionPoints = 100;
        weaponParams.shadynessPoints = 1;
        weaponParams.historicalPoints = 0;
        mod.characterWeapons = [
            WeaponGenerator.generate(weaponParams),
            WeaponGenerator.generate(weaponParams),
            WeaponGenerator.generate(weaponParams),
            WeaponGenerator.generate(weaponParams),
            null // For testing only
        ];
        mod.enemyWeapons = [
            WeaponGenerator.generate(weaponParams),
            WeaponGenerator.generate(weaponParams),
            WeaponGenerator.generate(weaponParams),
            WeaponGenerator.generate(weaponParams),
            WeaponGenerator.generate(weaponParams),
        ];
        weaponParams.shadynessPoints = 100;
        mod.characterWeapons.push(WeaponGenerator.generate(weaponParams));
        screenController.levelModifiers = mod;
    }
    
    override public function onExit(gameTime:GameTime):Void {
        FFLog.recordMenuEnd();
    }
    
    override public function update(gameTime:GameTime):Void {
        
    }
        
    override public function draw(gameTime:GameTime):Void {
        // Empty
    }
    
    // TODO: Remove startup load once menu is implemented
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
        screenController.loadedLevel = cast(Unserializer.run(data.toString()), GameLevel);

        screenController.switchToScreen(2);
    }
    
    private function initMainMenu():Void {
        //Create button from UISpriteFactory
        var uif:UISpriteFactory = new UISpriteFactory(Texture.fromBitmapData(Assets.getBitmapData("assets/img/UI.png")));
        
        //Set up formatting stuff
        var btf:ButtonTextFormat = {
            tx:120,
            ty:60,
            font:"Verdana", 
            size:20, 
            color:0x0, 
            bold:false, 
            hAlign:HAlign.CENTER, 
            vAlign:VAlign.CENTER
        };

        //Create Button and position it
        playButton = uif.createButton(175, 50, "PLAY", btf);
        tutorialButton = uif.createButton(175, 50, "TUTORIAL", btf);
        optionsButton = uif.createButton(175, 50, "SHOP", btf);
        
        //Translations
        playButton.transformationMatrix.translate(400 + playButton.width / 2, 170);
        tutorialButton.transformationMatrix.translate(400 + playButton.width / 2, 180 + tutorialButton.height);
        optionsButton.transformationMatrix.translate(400 + playButton.width / 2, 190 + 2*optionsButton.height);
        
        screenController.addChild(playButton);
        screenController.addChild(tutorialButton);
        screenController.addChild(optionsButton);
        
        playButton.bEvent.add(initLevelSelect);
    }
    
    private function exitMainMenu():Void {
        screenController.removeChild(playButton);
        screenController.removeChild(tutorialButton);
        screenController.removeChild(optionsButton);
        screenController.removeChild(levelButton);
        screenController.removeChild(confirmButton);
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
        prevButton = uif.createButton(100, 35, "BACK", btf);
        nextButton = uif.createButton(100, 35, "NEXT", btf);
        menuButton = uif.createButton(100, 35, "MAIN MENU", btf);
        confirmButton = uif.createButton(100, 35, "CONFIRM", btf);        
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
        confirmButton.bEvent.add(startLevel);
    }
    
    private function exitLevelSelect() {
        screenController.removeChild(prevButton);
        screenController.removeChild(nextButton);
        screenController.removeChild(levelButton);
        screenController.removeChild(menuButton);
    }
    
    //Initialize the array of level buttons (one for each level)
    private function initLevelButtonArray(uif:UISpriteFactory, btf:ButtonTextFormat):Void {
        var i:Int = 0;
        while (i <= MAX_LEVEL) {
            var button = uif.createButton(450, 225, "LEVEL " + (i + 1) , btf);
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
        if (optionsButton.clicked = true) { options = true; }
        else { options = false; }        
    }
}
