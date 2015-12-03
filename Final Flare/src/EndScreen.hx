package;

import lime.system.BackgroundWorker;
import sound.Composer;
import starling.display.DisplayObject;
import starling.display.Image;
import ui.Button;
import ui.Button.ButtonTextFormat;
import ui.UIPane;
import ui.UISpriteFactory;
import openfl.Assets;
import starling.display.Sprite;
import starling.textures.Texture;
import starling.utils.HAlign;
import starling.utils.VAlign;
import starling.text.TextField;


class EndScreen extends IGameScreen {
    private var backGround:Image;  //Background
    private var startButton:Button;
    private var mousePosX:Float;
    private var mousePosY:Float;
    private var myText:TextField;
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
        addScoreTextField();
        
       
    }
    
    override public function onExit(gameTime:GameTime):Void {
        screenController.removeChild(startButton);
        screenController.removeChild(myText);
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
    private function addScoreTextField() {
        
    
    myText= new TextField(300,300,(screenController.playerData.mostRecentVictory?"Victory":"Defeat")+"\n\nFinal Score: " + screenController.playerData.mostRecentScore,"Verdana", 50,0xFF0000,true);
    myText.x = 250;
    myText.y = 75;

    screenController.addChild(myText);   
    //flash.Lib.current.addEventListener(flash.events.Event.ENTER_FRAME,function(_) FontsTutorial.onEnterFrame());
  
        
        
        
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
        startButton = uif.createButton(200, 66, "Main Menu", btf, false);  
        startButton.transformationMatrix.translate(550, 325);
        
        screenController.addChild(startButton);
    }
}
