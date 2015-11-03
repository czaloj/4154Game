package;

import starling.display.Sprite;
import starling.textures.Texture;
import ui.UISpriteFactory;
import openfl.Assets;
import openfl.display.SimpleButton;

class SplashScreen extends IGameScreen {
    private var startButton:Sprite;
    private var startButtonUp:Sprite;
    private var startButtonHover:Sprite;
    private var startButtonPressed:Sprite;
    
    public function new(sc:ScreenController) {
        super(sc);
        var uif:UISpriteFactory = new UISpriteFactory(Texture.fromBitmapData(Assets.getBitmapData("assets/img/UI.png")));
        startButtonUp = uif.createButtonUp(200, 66);
        startButtonHover = uif.createButtonHover(200, 66);
        startButtonPressed = uif.createButtonPressed(200, 66);
    }
    
    override public function build():Void {
        // Empty
    }
    override public function destroy():Void {
        // Empty
    }
    
    override public function onEntry(gameTime:GameTime):Void {
        startButton = startButtonUp;
        startButton.transformationMatrix.translate(300, 250);
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
