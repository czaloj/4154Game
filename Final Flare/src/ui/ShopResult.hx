package ui;
import starling.display.DisplayObjectContainer;
import starling.display.DisplayObject;
import openfl.text.TextField;
import openfl.Assets;
import starling.display.Sprite;
import starling.textures.Texture;
import starling.utils.HAlign;
import starling.utils.VAlign;
import ui.Button;
import ui.Button.ButtonTextFormat;


class ShopResult extends DisplayObjectContainer { 
    public var s:Sprite;
    public var button:Button;
    
    public function new(d:DisplayObject) 
    {
        super();
        init(d);
    }
    
    public function init(d:DisplayObject) {
        
        var uif = new UISpriteFactory(Texture.fromBitmapData(Assets.getBitmapData("assets/img/UI.png")));
        
        //Set up formatting stuff
        var btf:ButtonTextFormat = {
            tx:100,
            ty:50,
            font:"BitFont",
            size:30,
            color:0xFFFFFF,
            bold:false,
            hAlign:HAlign.CENTER,
            vAlign:VAlign.BOTTOM
        };
        
        s = uif.createButtonPressed(400,225);
        button = uif.createButton(100, 50, "HOORAY" , btf, false);
        d.transformationMatrix.translate(s.bounds.width/2 - d.bounds.width/2, s.bounds.height/2 - d.bounds.height / 2);
        button.transformationMatrix.translate(200 - button.bounds.width / 2, 225/2 + button.bounds.height/2);
        s.addChild(d);
        s.addChild(button);
        this.addChild(s);
    }
}