package;

import lime.system.BackgroundWorker;
import openfl.events.MouseEvent;
import starling.display.Sprite;
import starling.textures.Texture;
import ui.UISpriteFactory;
import ui.Button;
import openfl.Assets;
import starling.text.TextField;
import openfl.Lib;

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
        var uif:UISpriteFactory = new UISpriteFactory(Texture.fromBitmapData(Assets.getBitmapData("assets/img/UI.png")));
        startButton = uif.createButton(200, 66);  
        //var tf:TextField = new TextField(175, 80, "Start Button", "Verdana", 20);
        //startButton.addChild(tf);
        screenController.addChild(startButton);
        
        
                       
    }
    override public function onExit(gameTime:GameTime):Void {
        screenController.removeChild(startButton);
    }
    
    override public function update(gameTime:GameTime):Void {
        // Switch to the main menu
        if (startButton.clicked) {
            startButton.clicked = false;
            screenController.switchToScreen(1);
        }
    }
    
    override public function draw(gameTime:GameTime):Void {
        // Empty
    }    
}
