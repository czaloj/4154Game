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

    private var plus10:Button;
    private var minus10:Button;
    private var plus100:Button;
    private var minus100:Button;
    private var numberBox:Sprite;
    public var maxAlloc:Int;
    public var allocated:Int;
    
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
        
        
        minus10 = uif.createButton(24, 24, "-10", btf, false);
        minus100 = uif.createButton(24, 24, "-100", btf, false);
        plus10 = uif.createButton(24, 24, "+10", btf, false);
        plus100 = uif.createButton(24, 24, "+100", btf, false);
        
        numberBox = new Sprite();
        tf  = new TextField(270, 40, s + Std.string(allocated), "BitFont", 40, 0xFFFFFF, false);
        tf.hAlign = HAlign.CENTER;
        tf.vAlign = VAlign.CENTER;
        numberBox.addChild(tf);
        
        minus10.transformationMatrix.translate(50, 0);
        minus100.transformationMatrix.translate(0, 0);
        plus10.transformationMatrix.translate(400, 0);
        plus100.transformationMatrix.translate(450, 0);
        numberBox.transformationMatrix.translate(110, 0); 

        this.addChild(minus10);
        minus10.bEvent.add(minusTen);
        this.addChild(minus100);
        minus100.bEvent.add(minusHundred);
        this.addChild(plus10);
        plus10.bEvent.add(plusTen);
        this.addChild(plus100);
        plus100.bEvent.add(plusHundred);
        this.addChild(numberBox);
        

    }
    
    public function disable() {
        minus10.enabled = false;
        minus100.enabled = false;
        plus10.enabled = false;
        plus100.enabled = false;
    }
    
    public function enable() {
        minus10.enabled = true;
        minus100.enabled = true;
        plus10.enabled = true;
        plus100.enabled = true;
    }
    
    public function allocate(value:Int) {
        allocated = allocated + value;
        if (allocated > maxAlloc) { allocated = maxAlloc; }
        if (allocated < 0) { allocated = 0; } 
        tf.text = string + Std.string(allocated);
    }
    
    private function minusTen() {
        allocate(-10);
    }
    private function plusTen() {
        allocate(10);
    }
    
    private function minusHundred() {
        allocate(-100);
    }
    
    private function plusHundred() {
        allocate(100);
    }    
}