package;

import game.GameLevel;
import game.MenuLevelModifiers;
import haxe.Unserializer;
import openfl.events.Event;
import flash.net.FileReference;
import flash.utils.ByteArray;
import weapon.WeaponGenerator;
import weapon.WeaponGenParams;
import openfl.events.MouseEvent;
import starling.display.Sprite;
import starling.textures.Texture;
import ui.UISpriteFactory;
import openfl.Assets;
import starling.text.TextField;
import openfl.Lib;


class MenuScreen extends IGameScreen {
    private var buttonArray1:Array<Sprite>;
    private var buttonArray2:Array<Sprite>;
    private var button1:Sprite;
    private var button2:Sprite;
    
    
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
        var uif:UISpriteFactory = new UISpriteFactory(Texture.fromBitmapData(Assets.getBitmapData("assets/img/UI.png")));
        buttonArray1 = uif.createButton(175, 50);
        buttonArray2 = uif.createButton(175, 50);
        Lib.current.stage.addEventListener(MouseEvent.CLICK, handleClick);
        
        //Arena 1 Button
        
        button1 = buttonArray1[0];        
        var tf1:TextField = new TextField(160, 50, "Level 1", "Verdana", 20);
        button1.addChild(tf1);
        buttonArray1[0].transformationMatrix.translate(170, 175);
        buttonArray1[1].transformationMatrix.translate(170, 175);
        buttonArray1[2].transformationMatrix.translate(170, 175);
        screenController.addChild(button1);
        
        //Arena 2 Button
        button2 = buttonArray2[0];        
        var tf2:TextField = new TextField(150, 50, "Level 2", "Verdana", 20);
        button2.addChild(tf2);
        buttonArray2[0].transformationMatrix.translate(425, 175);
        buttonArray2[1].transformationMatrix.translate(425, 175);
        buttonArray2[2].transformationMatrix.translate(425, 175);
        screenController.addChild(button2);        
        
        
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
            WeaponGenerator.generate(weaponParams)
        ];
        screenController.levelModifiers = mod;
    }
    override public function onExit(gameTime:GameTime):Void {
        Lib.current.stage.removeEventListener(MouseEvent.CLICK, handleClick);
        screenController.removeChild(button1);
        screenController.removeChild(button2);
        FFLog.recordMenuEnd();
        Lib.current.stage.removeEventListener(MouseEvent.CLICK, handleClick);

    }
    
    override public function update(gameTime:GameTime):Void {
        // Empty
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
    
    private function handleClick(e:MouseEvent):Void {
        var bound1 = button1.getBounds(screenController);
        var bound2 = button2.getBounds(screenController);
        if (bound1.contains(e.stageX, e.stageY)) {
            changeButtonState(1, 2);
            screenController.loadedLevel = LevelCreator.loadLevelFromFile("assets/level/test.lvl");
            screenController.switchToScreen(2);
        }
        else if (bound2.contains(e.stageX, e.stageY)) {
            //changeButtonState(2, 2);
        }
        
    }
    
    //Future Mark, I'm sorry
    //This implementation is so disgusting. Change ASAP
    public function changeButtonState(button:Int, state:Int):Void
    {
        if (button == 1) {
            screenController.removeChild(button1);
            button1 = buttonArray1[state];        
            var tf:TextField = new TextField(150, 50, "Level 1", "Verdana", 20);
            button1.addChild(tf);
            screenController.addChild(button1);
        }
        
        else if (button == 2) {
            screenController.removeChild(button2);
            button2 = buttonArray2[state];        
            var tf:TextField = new TextField(150, 50, "Level 2", "Verdana", 20);
            button2.addChild(tf);
            screenController.addChild(button2);
        }
    }
}
