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
    private var maxAlloc:Int = 0;
    private var allocated:Int = 0;
    
    public var string:String;
    public var tf:TextField;
    
    public function new(s:String, p:Int) 
    {
        super();
        init(s, p);
    }
    
    public function init(s:String, p:Int) {
        
        string = s;
        allocated = 0;
        maxAlloc = p;
        var uif = new UISpriteFactory(Texture.fromBitmapData(Assets.getBitmapData("assets/img/UI.png")));
        
        //Set up formatting stuff
        var btf:ButtonTextFormat = {
            tx:32,
            ty:32,
            font:"BitFont",
            size:30,
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
        
        
        minus1 = uif.createButton(24, 24, "-1", btf, false);
        minus10 = uif.createButton(24, 24, "-10", btf, false);
        plus1 = uif.createButton(24, 24, "+1", btf, false);
        plus10 = uif.createButton(24, 24, "+10", btf, false);
        
        numberBox = new Sprite();
        tf  = new TextField(270, 40, s + Std.string(allocated), "BitFont", 40, 0xFFFFFF, false);
        tf.hAlign = HAlign.CENTER;
        tf.vAlign = VAlign.CENTER;
        numberBox.addChild(tf);
        
        minus1.transformationMatrix.translate(50, 0);
        minus10.transformationMatrix.translate(0, 0);
        plus1.transformationMatrix.translate(400, 0);
        plus10.transformationMatrix.translate(450, 0);
        numberBox.transformationMatrix.translate(110, 0); 

        this.addChild(minus1);
        minus1.bEvent.add(minusOne);
        this.addChild(minus10);
        minus10.bEvent.add(minusTen);
        this.addChild(plus1);
        plus1.bEvent.add(plusOne);
        this.addChild(plus10);
        plus10.bEvent.add(plusTen);
        this.addChild(numberBox);
        

    }
    
    public function disable() {
        minus1.enabled = false;
        minus10.enabled = false;
        plus1.enabled = false;
        plus10.enabled = false;
    }
    
    private function allocate(value:Int) {
        allocated = (allocated + value);
        if (allocated > maxAlloc) { allocated = maxAlloc; }
        if (allocated < 0) { allocated = 0; } 
        tf.text = string + Std.string(allocated);
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