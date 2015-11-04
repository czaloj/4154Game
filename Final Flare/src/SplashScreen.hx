package;

import lime.system.BackgroundWorker;
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
    
	private function addStartButton() 
	{
		//Create button from UISpriteFactory
		var uif:UISpriteFactory = new UISpriteFactory(Texture.fromBitmapData(Assets.getBitmapData("assets/img/UI.png")));
		
		//Set up formatting stuff
		/*var tf = new ButtonTextFormat();
		tf.tx = 0;
		tf.ty = 0;
		tf.color = 0x0;
		tf.hAlign = HAlign.CENTER;
		tf.vAlign = VAlign.CENTER;
		tf.bold = false;
		tf.font = "Verdana";*/
		
		//Create Button and position it
        startButton = uif.createButton(200, 66, "START GAME", tf);  
        startButton.transformationMatrix.translate(screenController.width - startButton.width / 2, (startButton.height * 3) / 2);
        screenController.addChild(startButton);
	}

}
