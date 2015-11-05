package;

import lime.system.BackgroundWorker;
import openfl.events.MouseEvent;
import starling.display.Sprite;
import starling.textures.Texture;
import ui.UISpriteFactory;
import openfl.Assets;
import openfl.display.SimpleButton;
import starling.text.TextField;
import openfl.Lib;

class SplashScreen extends IGameScreen {
    private var buttonArray:Array<Sprite>;
    private var startButton:Sprite;
    
    private var mousePosX:Float;
    private var mousePosY:Float;
    private var clicked:Bool = false;
    private var hover:Bool = false;
    
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
        buttonArray = uif.createButton(200, 66);
        //Lib.current.stage.addEventListener(MouseEvent.MOUSE_MOVE, updateMouse);
        Lib.current.stage.addEventListener(MouseEvent.CLICK, handleClick);
        
        startButton = buttonArray[0];        
        var tf:TextField = new TextField(175, 80, "Start Button", "Font", 20);
        startButton.addChild(tf);
        buttonArray[0].transformationMatrix.translate(275, 250);
        buttonArray[2].transformationMatrix.translate(275, 250);
        screenController.addChild(startButton);
        
        
        
    }
    override public function onExit(gameTime:GameTime):Void {
        Lib.current.stage.removeEventListener(MouseEvent.CLICK, handleClick);
        screenController.removeChild(startButton);
    }
    
    override public function update(gameTime:GameTime):Void {
        if ((startButton.getBounds(screenController)).contains(mousePosX, mousePosY) && hover == false)
        {
            changeButtonState(1);
            hover = true;
        }
        if ((startButton.getBounds(screenController)).contains(mousePosX, mousePosY) == false && hover == true)
        {
            hover == false;
            changeButtonState(0);
  
        }
        
        
        // Switch to the main menu
        if (clicked) {
            clicked = false;
            screenController.switchToScreen(1);
        }
    }
    override public function draw(gameTime:GameTime):Void {
        // Empty
    }
    
    public function changeButtonState(state:Int) 
    {
        screenController.removeChild(startButton);
        startButton = buttonArray[state];        
        var tf:TextField = new TextField(175, 80, "Start Button", "Font", 20);
        startButton.addChild(tf);
        screenController.addChild(startButton);
    }
    
    public function updateMouse(e:MouseEvent):Void {
        mousePosX = e.stageX;
        mousePosY = e.stageY;
    }
    
    public function handleClick(e:MouseEvent):Void {
        var bound = startButton.getBounds(screenController);
        if (bound.contains(e.stageX, e.stageY)) {
            clicked = true;
            changeButtonState(2);
        }
    }
    
}
