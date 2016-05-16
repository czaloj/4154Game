package;

import graphics.PositionalAnimator.PAFrame;
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
import ui.PanelSprite;
import ui.UIPane;
import ui.UISpriteFactory;
import starling.display.Sprite;
import starling.textures.Texture;
import starling.utils.HAlign;
import starling.utils.VAlign;

class SplashScreen extends IGameScreen {
    private var backGround:Image;  //Background
    private var startButton:Button;
    private var transitionStart:PanelSprite;
    private var mousePosX:Float;
    private var mousePosY:Float;
    
    public function new(sc:ScreenController) {
        super(sc);
    }
    
    override public function build():Void {
        //Set up formatting stuff
        var btf:ButtonTextFormat = {
            tx:150,
            ty:75,
            font:"BitFont", 
            size:75, 
            color:0x0077FF, 
            bold:false, 
            hAlign:HAlign.CENTER, 
            vAlign:VAlign.CENTER
        };

        //Create Button and position it
        startButton = screenController.uif.createButton(200, 66, "START GAME", btf, false);  
        transitionStart = new PanelSprite(startButton, [0.4], [
            new PAFrame(-startButton.width / 2, 300, 0),
            new PAFrame(-startButton.width / 2, 0, 0)
        ]);
        transitionStart.transformationMatrix.translate(400, 300);
    }
    override public function destroy():Void {
        // Empty
    }
    
    override public function onEntry(gameTime:GameTime):Void {
        backGround = new Image(Texture.fromBitmapData(Assets.getBitmapData("assets/img/TitleScreen.png")));
        screenController.addChild(backGround);
        screenController.addChild(transitionStart);
        transitionStart.extend();
    }
    
    override public function onExit(gameTime:GameTime):Void {
        transitionStart.retract();
        screenController.removeChild(backGround);
        backGround.texture.dispose();
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
}
