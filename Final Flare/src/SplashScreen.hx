package;

import starling.display.Sprite;
import starling.textures.Texture;
import ui.UISpriteFactory;
import openfl.Assets;
import openfl.display.SimpleButton;

class SplashScreen extends IGameScreen {
    private var startButton:Sprite;
    
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
        
        var startButton = uif.createSquareButton();
        screenController.addChild(startButton);
        
        
    }
    override public function onExit(gameTime:GameTime):Void {
        // Empty
    }
    
    override public function update(gameTime:GameTime):Void {
        // TODO: Add real switching
        
        // Switch to the main menu
        screenController.switchToScreen(1);
    }
    override public function draw(gameTime:GameTime):Void {
        // Empty
    }    
}
