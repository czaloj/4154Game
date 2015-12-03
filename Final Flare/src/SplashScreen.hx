package;

import lime.system.BackgroundWorker;
import openfl.Lib.current;
import openfl.Assets;
import openfl.text.TextField;
import openfl.text.TextFieldAutoSize;
import openfl.text.TextFieldType;
import openfl.text.TextFormat;
import openfl.text.TextFormatAlign;
import sound.Composer;
import starling.display.DisplayObject;
import starling.display.Image;
import ui.Button;
import ui.Button.ButtonTextFormat;
import ui.UIPane;
import ui.UISpriteFactory;
import starling.display.Sprite;
import starling.textures.Texture;
import starling.utils.HAlign;
import starling.utils.VAlign;

class SplashScreen extends IGameScreen {
    private var backGround:Image;  //Background
    private var startButton:Button;
    private var mousePosX:Float;
    private var mousePosY:Float;
    
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
        backGround = new Image(Texture.fromBitmapData(Assets.getBitmapData("assets/img/TitleScreen.png")));
        screenController.addChild(backGround);
        addStartButton();

        Composer.playMusicTrack("Menu" + Std.string(Std.int(Math.random() * 3 + 1))); // TODO: Just tell composer to play menu music
    }
    
    override public function onExit(gameTime:GameTime):Void {
        screenController.removeChild(startButton);
        screenController.removeChild(backGround);
    }
    
    override public function update(gameTime:GameTime):Void {
        // Switch to the main menu
        if (startButton.clicked && Composer.isLoadingComplete) {
            screenController.switchToScreen(1);
        }
    }
    
    override public function draw(gameTime:GameTime):Void {
        // Empty
    }
    
    private function addStartButton() 
    {
        //Create button from UISpriteFactory
        var uif:UISpriteFactory = new UISpriteFactory(Texture.fromBitmapData(Assets.getBitmapData("assets/img/UI.png")));
        
        //Set up formatting stuff
        var btf:ButtonTextFormat = {
            tx:150,
            ty:75,
            font:"BitFont", 
            size:20, 
            color:0x0, 
            bold:false, 
            hAlign:HAlign.CENTER, 
            vAlign:VAlign.CENTER
        };

        //Create Button and position it
        startButton = uif.createButton(200, 66, "START GAME", btf, false);  
        startButton.transformationMatrix.translate(400 - startButton.width / 2, 300);
        
        screenController.addChild(startButton);
    }
}
