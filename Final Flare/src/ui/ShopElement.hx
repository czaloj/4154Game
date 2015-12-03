package ui;

import openfl.Assets;
import starling.display.Sprite;
import starling.text.TextField;
import ui.Button;
import ui.Button.ButtonTextFormat;
import starling.textures.Texture;
import starling.utils.HAlign;
import starling.utils.VAlign;
import starling.display.DisplayObjectContainer;


class ShopElement extends DisplayObjectContainer
{

    private var plus1:Button;
    private var minus1:Button;
    private var plus10:Button;
    private var minus10:Button;
    private var numberBox:Sprite;
    private var allocated:Int;
    
    public function new() 
    {
        super();
        init();
    }
    
    public function init() {
        
        var uif = new UISpriteFactory(Texture.fromBitmapData(Assets.getBitmapData("assets/img/UI.png")));
        
        //Set up formatting stuff
        var btf:ButtonTextFormat = {
            tx:16,
            ty:16,
            font:"BitFont",
            size:16,
            color:0xFFFFFF,
            bold:false,
            hAlign:HAlign.CENTER,
            vAlign:VAlign.CENTER
        };
        
        //Set up formatting stuff
        var btf2:ButtonTextFormat = {
            tx:0,
            ty:0,
            font:"Bitfont",
            size:20,
            color:0x0,
            bold:false,
            hAlign:HAlign.CENTER,
            vAlign:VAlign.CENTER
        };
        
        
        minus1 = uif.createButton(16, 16, "-1", btf, true);
        minus10 = uif.createButton(16, 16, "-10", btf, true);
        plus1 = uif.createButton(16, 16, "+1", btf, true);
        plus10 = uif.createButton(16, 16, "+10", btf2, false);
        
        numberBox = new Sprite();
        
        minus1.transformationMatrix.translate(0, numberBox.height/2);
        minus10.transformationMatrix.translate(28, numberBox.height / 2);
        plus1.transformationMatrix.translate(56, numberBox.height / 2);
        plus1.transformationMatrix.translate(84, numberBox.height/2);

        
        this.addChild(minus1);
        minus1.bEvent.add(minusOne);
        this.addChild(minus10);
        minus10.bEvent.add(minusTen);
        this.addChild(plus1);
        plus1.bEvent.add(plusOne);
        this.addChild(plus10);
        plus10.bEvent.add(plusTen);
        this.addChild(numberBox);
        
        var tf:TextField = new TextField(30, 30, "0", "BitFont", 12, 0x0, false);
        numberBox.addChild(tf);
    }
    
    private function allocate(value:Int) {
        allocated = (allocated + value);    
    }
    
    private function minusOne() {
        allocate(-1);
    }
    private function plusOne() {
        allocate(1);
    }
    
    private function minusTen() {
        allocate(-10);
    }
    
    private function plusTen() {
        allocate(10);
    }    
}