package;

import graphics.PositionalAnimator.PAFrame;
import starling.core.Starling;
import starling.display.Image;
import starling.textures.Texture;
import starling.utils.HAlign;
import starling.utils.VAlign;
import openfl.Assets;
import ui.Button;
import ui.PanelSprite;

class LevelSelectScreen extends IGameScreen{
    private var textureBackground:Texture;
    private var background:Image;

    private var btnBack:Button;
    private var transitionButtons:Array<PanelSprite>;
    
    public function new(sc:ScreenController) {
        super(sc);
    }
    
    override public function build():Void {
        // Load the background image
        textureBackground = Texture.fromBitmapData(Assets.getBitmapData("assets/img/BackgroundLevelSelect.png"), false, false, 1, null, false);
        background = new Image(textureBackground);
        
        // Create the buttons
        var btf:ButtonTextFormat = {
            tx:160,
            ty:50,
            bold:false,
            color:0xffffffff,
            font:"BitFont",
            hAlign:HAlign.CENTER,
            vAlign:VAlign.CENTER,
            size:50
        };
        
        transitionButtons = [];
        function createButton(x:Float, y:Float, dx:Float, dy:Float, text:String, delay:Float):Button {
            var TRANSITION_BUFFER_PERIOD = 0.4;
            var TRANSITION_TOTAL_TIME = 0.6;
            var b:Button = screenController.uif.createButton(160, 50, text, btf, false);
            var p:PanelSprite = new PanelSprite(b, [delay, TRANSITION_TOTAL_TIME - TRANSITION_BUFFER_PERIOD, TRANSITION_BUFFER_PERIOD - delay], [
                new PAFrame(dx, dy, 0),
                new PAFrame(dx, dy, 0),
                new PAFrame(0, 0, 0),
                new PAFrame(0, 0, 0)
            ]);
            p.x = x;
            p.y = y;
            transitionButtons.push(p);
            return b;
        }
        
        btnBack = createButton(0, Starling.current.stage.stageHeight - 50, 0, 50, "Back", 0.1);
        btnBack.bEvent.add(function():Void {
            screenController.switchToScreen(1);
        });
    }
    override public function destroy():Void {
        textureBackground.dispose();
    }

    override public function onEntry(gameTime:GameTime):Void {
        screenController.addChildAt(background, 0);
        for (p in transitionButtons) p.readdTo(screenController);
    }
    override public function onExit(gameTime:GameTime):Void {
        screenController.removeChild(background);
        for (p in transitionButtons) p.retract();
    }
    
    override public function update(gameTime:GameTime):Void {
        // Empty
    }
    override public function draw(gameTime:GameTime):Void {
        // Empty
    }
}