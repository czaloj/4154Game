package;

import lime.system.BackgroundWorker;
import sound.Composer;
import ui.Button;
import ui.Button.ButtonTextFormat;
import ui.UISpriteFactory;
import openfl.Assets;
import starling.display.Sprite;
import starling.textures.Texture;
import starling.utils.HAlign;
import starling.utils.VAlign;
import starling.text.TextField;

class SplashScreen extends IGameScreen {
    private var startButton:Button;
    private var mousePosX:Float;
    private var mousePosY:Float;
    private var clicked:Bool = false;
    
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
        addStartButton();
        
        Composer.playMusicTrack("Menu");
    }
    
    override public function onExit(gameTime:GameTime):Void {
        screenController.removeChild(startButton);
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
            font:"Verdana", 
            size:20, 
            color:0x0, 
            bold:false, 
            hAlign:HAlign.CENTER, 
            vAlign:VAlign.CENTER
        };

        //Create Button and position it
        startButton = uif.createButton(200, 66, "START GAME", btf);  
        startButton.transformationMatrix.translate(400 - startButton.width / 2, 250);
        
        screenController.addChild(startButton);
    }
}
