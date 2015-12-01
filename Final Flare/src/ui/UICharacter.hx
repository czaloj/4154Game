package ui;

import openfl.Assets;
import ui.Button;
import ui.Button.ButtonTextFormat;
import starling.display.Image;
import starling.textures.Texture;
import starling.utils.HAlign;
import starling.utils.VAlign;
import starling.display.DisplayObjectContainer;


class UICharacter extends DisplayObjectContainer
{

    private var charImage:Image;
    public var charButton:Button;
    private var prevButton:Button;
    private var nextButton:Button;
    
    private var queuePos:Int;
    
    public function new(i:Image = null) 
    {
        super();
        init(i);
    }
    
    public function init(i:Image = null) {
        
        var uif = new UISpriteFactory(Texture.fromBitmapData(Assets.getBitmapData("assets/img/UI.png")));
        
        //Set up formatting stuff
        var btf:ButtonTextFormat = {
            tx:60,
            ty:120,
            font:"Verdana",
            size:20,
            color:0x0,
            bold:false,
            hAlign:HAlign.CENTER,
            vAlign:VAlign.CENTER
        };
        
        //Set up formatting stuff
        var btf2:ButtonTextFormat = {
            tx:0,
            ty:0,
            font:"Verdana",
            size:20,
            color:0x0,
            bold:false,
            hAlign:HAlign.CENTER,
            vAlign:VAlign.CENTER
        };
        
        charButton = uif.createButton(59, 119, "1", btf, true);
        prevButton = uif.createButton(4, 0, "", btf2, false);
        nextButton = uif.createButton(4, 0, "", btf2, false);
        
        prevButton.transformationMatrix.translate(0, 193);
        charButton.transformationMatrix.translate(28, 50);
        nextButton.transformationMatrix.translate(charButton.bounds.x + charButton.width + 8, charButton.bounds.y + charButton.height + 8);
        
        this.addChild(charButton);
        this.addChild(nextButton);
        this.addChild(prevButton);
    }
    
}