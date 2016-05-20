package ui;
import starling.display.Sprite;
import starling.events.Event;
import starling.text.TextField;
import starling.utils.HAlign;

typedef SButton = starling.display.Button;

class NumberInput extends Sprite {
    private var btnMinus3:SButton;
    private var btnMinus2:SButton;
    private var btnMinus1:SButton;
    private var btnPlus1:SButton;
    private var btnPlus2:SButton;
    private var btnPlus3:SButton;
    
    private var number:Int;
    private var min:Int;
    private var max:Int;
    
    private var text:TextField;
    
    public var value(get, set):Int;
    public function get_value():Int {
        return number;
    }
    public function set_value(v:Int):Int {
        number = v;
        if (number < min) number = min;
        else if (number > max) number = max;
        text.text = "" + number;
        return number;
    }
    
    public function new(uif:UISpriteFactory, d1:Int, d2:Int, d3:Int, min:Int, max:Int) {
        super();
        
        this.min = min;
        this.max = max;
        
        btnMinus3 = new SButton(uif.getSubtexture("NI.Minus3.Normal"), "", uif.getSubtexture("NI.Minus3.Hover"), uif.getSubtexture("NI.Minus3.Press"));
        btnMinus2 = new SButton(uif.getSubtexture("NI.Minus2.Normal"), "", uif.getSubtexture("NI.Minus2.Hover"), uif.getSubtexture("NI.Minus2.Press"));
        btnMinus1 = new SButton(uif.getSubtexture("NI.Minus1.Normal"), "", uif.getSubtexture("NI.Minus1.Hover"), uif.getSubtexture("NI.Minus1.Press"));
        btnPlus1 = new SButton(uif.getSubtexture("NI.Plus1.Normal"), "", uif.getSubtexture("NI.Plus1.Hover"), uif.getSubtexture("NI.Plus1.Press"));
        btnPlus2 = new SButton(uif.getSubtexture("NI.Plus2.Normal"), "", uif.getSubtexture("NI.Plus2.Hover"), uif.getSubtexture("NI.Plus2.Press"));
        btnPlus3 = new SButton(uif.getSubtexture("NI.Plus3.Normal"), "", uif.getSubtexture("NI.Plus3.Hover"), uif.getSubtexture("NI.Plus3.Press"));

        btnMinus3.x = 0;
        btnMinus2.x = 24;
        btnMinus1.x = 48;
        btnPlus1.x = 172;
        btnPlus2.x = 196;
        btnPlus3.x = 220;
        
        addChild(btnMinus3);
        addChild(btnMinus2);
        addChild(btnMinus1);
        addChild(btnPlus1);
        addChild(btnPlus2);
        addChild(btnPlus3);
        
        btnMinus3.addEventListener(Event.TRIGGERED, function(e:Event):Void { value -= d3; });
        btnMinus2.addEventListener(Event.TRIGGERED, function(e:Event):Void { value -= d2; });
        btnMinus1.addEventListener(Event.TRIGGERED, function(e:Event):Void { value -= d1; });
        btnPlus1.addEventListener(Event.TRIGGERED, function(e:Event):Void { value += d1; });
        btnPlus2.addEventListener(Event.TRIGGERED, function(e:Event):Void { value += d2; });
        btnPlus3.addEventListener(Event.TRIGGERED, function(e:Event):Void { value += d3; });
        
        number = 0;
        text = new TextField(100, 32, "0", "BitFont", 32, 0xffffffff, false);
        text.x = 72;
        text.hAlign = HAlign.CENTER;
        text.autoScale = false;
        addChild(text);
    }
    
    public function setMax(v:Int):Void {
        max = v;
        if (value > max) value = max;
    }
}