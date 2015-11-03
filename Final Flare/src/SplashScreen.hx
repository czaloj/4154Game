package;

import lime.system.BackgroundWorker;
import starling.events.Event;
import openfl.events.MouseEvent;
import starling.display.Sprite;
import starling.textures.Texture;
import ui.UISpriteFactory;
import openfl.Assets;
import openfl.display.SimpleButton;
import starling.text.TextField;
import starling.utils.HAlign;

class SplashScreen extends IGameScreen {
    private var buttonArray:Array<Sprite>;
    private var startButton:Sprite;
    
    private var mousePosX:Float;
    private var mousePosY:Float;
    private var clicked:Bool = false;
    
    public function new(sc:ScreenController) {
        super(sc);
        var uif:UISpriteFactory = new UISpriteFactory(Texture.fromBitmapData(Assets.getBitmapData("assets/img/UI.png")));
        buttonArray = uif.createButton(200, 66);
    }
    
    override public function build():Void {
        // Empty
    }
    override public function destroy():Void {
        // Empty
    }
    
    override public function onEntry(gameTime:GameTime):Void {
        startButton = buttonArray[0];
        
        var tf:TextField = new TextField(175, 80, "Start Button", "Verdana", 20);
        tf.hAlign = HAlign.CENTER;
        startButton.addChild(tf);
        startButton.transformationMatrix.translate(300, 250);
        startButton.addEventListener(MouseEvent.MOUSE_MOVE, handleHover);
        screenController.addChild(startButton);
        
        
        
    }
    override public function onExit(gameTime:GameTime):Void {
        // Empty
    }
    
    override public function update(gameTime:GameTime):Void {
        // Switch to the main menu
        if (clicked) {
            clicked = false;
            screenController.switchToScreen(1);
        }
    }
    override public function draw(gameTime:GameTime):Void {
        // Empty
    }
    
    public function handleHover(e:MouseEvent = null):Void {
        trace("hover");
    }
    
    public function handleClick(e:MouseEvent = null):Void {
        trace("Click");
    }
    
}
