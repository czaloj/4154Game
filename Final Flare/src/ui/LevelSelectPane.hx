package ui;

import ui.Button;
import ui.Button.ButtonTextFormat;
import ui.UISpriteFactory;
import openfl.Assets;
import starling.display.Sprite;
import starling.textures.Texture;
import starling.utils.HAlign;
import starling.utils.VAlign;

class LevelSelectPane extends UIPane
{
    private static var MAX_LEVEL:Int = 2;
    public var selectedLevel:Int;
    
    //Buttons
    public var menuButton:Button;
    public var confirmButton:Button;
    
    private var levelButton:Button;
    private var levelButtonArray:Array<Button> = new Array<Button>();
    
    public function new() 
    {
        super();
        init();
    }
    
    public function init():Void {
        selectedLevel = 0;

        var uif = new UISpriteFactory(Texture.fromBitmapData(Assets.getBitmapData("assets/img/UI.png")));
        //Set up formatting stuff
        
        var btf:ButtonTextFormat = {
            tx:100,
            ty:35,
            font:"BitFont",
            size:50,
            color:0xFFFFFF,
            bold:false,
            hAlign:HAlign.CENTER,
            vAlign:VAlign.CENTER
        };

        initLevelButtonArray(uif, btf);

        //TODO make custon btf for each button if necessary
        var prevButton = uif.createButton(100, 35, "BACK", btf, false);
        var nextButton = uif.createButton(100, 35, "NEXT", btf, false);
        var levelButton = levelButtonArray[selectedLevel];
        
        menuButton = uif.createButton(100, 35, "MAIN MENU", btf, false);
        confirmButton = uif.createButton(100, 35, "CONFIRM", btf, false);

        
        //Add functions to event subscribers lists
        prevButton.bEvent.add(decrementLevel);
        prevButton.bEvent.add(updateLevelButton);
        nextButton.bEvent.add(incrementLevel);
        nextButton.bEvent.add(updateLevelButton);
        
        this.add(prevButton, 400 - levelButton.width / 2, 375);
        this.add(nextButton, 400 - levelButton.width / 2 + levelButton.width - nextButton.width, 375);
        this.add(levelButton);
        this.add(confirmButton, 400 - confirmButton.width / 2, 375);
        this.add(menuButton, 25, 25);

        
    }
    
    //Initialize the array of level buttons (one for each level)
    private function initLevelButtonArray(uif:UISpriteFactory, btf:ButtonTextFormat):Void {
        var i:Int = 0;
        while (i <= MAX_LEVEL) {
            var button = uif.createButton(450, 225, "LEVEL " + (i + 1) , btf, false);
            button.transformationMatrix.translate(400 - button.width / 2, 200 - button.height / 2);
            levelButtonArray.push(button);
            i++;
        }
    }

    private function updateLevelButton():Void {
        this.removeChild(levelButton);
        levelButton = levelButtonArray[selectedLevel];
        this.addChild(levelButton);
    }

    private function changeLevel(delta:Int):Void {
        selectedLevel += delta;
        if (selectedLevel < 0) { selectedLevel = 0; }
        if (selectedLevel > MAX_LEVEL) { selectedLevel = MAX_LEVEL; }
    }

    private function decrementLevel():Void {
        changeLevel(-1);
    }

    private function incrementLevel():Void {
        changeLevel(1);
    }
    
}