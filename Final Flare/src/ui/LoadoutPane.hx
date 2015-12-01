package ui;

import ui.Button;
import ui.UICharacter;
import ui.Button.ButtonTextFormat;
import ui.UISpriteFactory;
import openfl.Assets;
import starling.display.Sprite;
import starling.textures.Texture;
import starling.utils.HAlign;
import starling.utils.VAlign;
import starling.text.TextField;

class LoadoutPane extends UIPane
{
    private var charButtonArray:Array<Button>; 
    
    private var char1:UICharacter;
    private var char2:UICharacter;
    private var char3:UICharacter;
    private var char4:UICharacter;
    private var char5:UICharacter;
    
    private var firstSelectedSprite:Sprite;
    private var secondSelectedSprite:Sprite;
    private var thirdSelectedSprite:Sprite;
    
    private var numSelected:Int = 0;  //Logic stuff
    

    public function new() 
    {
        super();
        init();
    }
    
    public function init():Void {
        //Used to make Buttons
        var uif = new UISpriteFactory(Texture.fromBitmapData(Assets.getBitmapData("assets/img/UI.png")));
        
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
        
        //init char button array

        char1 = new UICharacter();
        char2 = new UICharacter();
        char3 = new UICharacter();
        char4 = new UICharacter();
        char5 = new UICharacter();
        
        this.add(char1, 24, 0);
        this.add(char2, char1.bounds.x + char1.width + 24, 0);
        this.add(char3, char2.bounds.x + char2.width + 24, 0);
        this.add(char4, char3.bounds.x + char3.width + 24, 0);
        this.add(char5, char4.bounds.x + char4.width + 24, 0);
        
        charButtonArray = new Array<Button>();
        charButtonArray.push(char1.charButton);
        charButtonArray.push(char2.charButton);
        charButtonArray.push(char3.charButton);
        charButtonArray.push(char4.charButton);
        charButtonArray.push(char5.charButton);
        
        var i = 0;
        while (i < charButtonArray.length) {
            charButtonArray[i].bEvent1.add(selectChar);
            i++;
        }
        
        firstSelectedSprite = new Sprite();
        var tf1:TextField = new TextField(30, 30, "1", "Verdana", 20, 0xFFFFFF, true);
        tf1.hAlign = HAlign.CENTER;
        tf1.vAlign = VAlign.CENTER;
        firstSelectedSprite.addChild(tf1);
        
        secondSelectedSprite = new Sprite();
        var tf2:TextField = new TextField(30, 30, "2", "Verdana", 20, 0xFFFFFF, true);
        tf2.hAlign = HAlign.CENTER;
        tf2.vAlign = VAlign.CENTER;
        secondSelectedSprite.addChild(tf2);
        
        thirdSelectedSprite = new Sprite();
        var tf3:TextField = new TextField(30, 30, "3", "Verdana", 20, 0xFFFFFF, true);
        tf3.hAlign = HAlign.CENTER;
        tf3.vAlign = VAlign.CENTER;
        thirdSelectedSprite.addChild(tf3);
    }
    
    private function selectChar(b:Button) {
        switch numSelected {
            case 0:
                firstSelectedSprite.transformationMatrix.translate(b.bounds.x + b.width/2 - 15, b.bounds.y - 35);
                this.addChild(firstSelectedSprite);
                b.customData = 1;
                numSelected++;
            case 1:
                if (b.customData == 0) {
                    secondSelectedSprite.transformationMatrix.translate(b.bounds.x + b.width/2 - 15, b.bounds.y - 35);
                    this.addChild(secondSelectedSprite);
                    b.customData = 2;
                    numSelected++;
                }
                else {
                    adjustCharSelect(b, b.customData);
                }
            case 2:
                if (b.customData == 0) {
                    thirdSelectedSprite.transformationMatrix.translate(b.bounds.x + b.width/2 - 15, b.bounds.y - 30);
                    this.addChild(thirdSelectedSprite);
                    b.customData = 3;
                    numSelected++;
                }
                else {
                    adjustCharSelect(b, b.customData);
                }
            case 3:
                if (b.customData != 0) {
                    adjustCharSelect(b, b.customData);
                }
        }
        
        if (numSelected == 3) {
            var b = 0;
            while (b < charButtonArray.length) {
                if (charButtonArray[b].customData == 0) { charButtonArray[b].enabled = false; }
                b++;
            }
        }
    }
    
    //Super hacky way to do char select 
    private function adjustCharSelect(b:Button, i:Int):Void {
        switch numSelected {
            case 1:
                var x1 = firstSelectedSprite.bounds.x;
                var y1 = firstSelectedSprite.bounds.y;
               
                firstSelectedSprite.transformationMatrix.translate( -x1, -y1);
                this.removeChild(firstSelectedSprite);
                b.customData = 0;
                
                numSelected--;
                
            case 2:
                var x2 = secondSelectedSprite.bounds.x;
                var y2 = secondSelectedSprite.bounds.y;
                secondSelectedSprite.transformationMatrix.translate( -x2, -y2);
                this.removeChild(secondSelectedSprite);
                b.customData = 0;
                numSelected--;

                if (i == 1) {
                    var x1 = firstSelectedSprite.bounds.x;
                    var y1 = firstSelectedSprite.bounds.y;
                    
                    firstSelectedSprite.transformationMatrix.translate( -x1, -y1);                    
                    firstSelectedSprite.transformationMatrix.translate(x2, y2);
                    
                    var b = 0;
                    while (b < charButtonArray.length) {
                        if (charButtonArray[b].customData == 2) { charButtonArray[b].customData = 1; }
                        else {charButtonArray[b].customData = 0; }
                        b++;
                    }
                }
                
            case 3:
                var x3 = thirdSelectedSprite.bounds.x;
                var y3 = thirdSelectedSprite.bounds.y;
                thirdSelectedSprite.transformationMatrix.translate(-x3,-y3);
                this.removeChild(thirdSelectedSprite);
                numSelected--; 
                
                b.customData = 0;

                
                if (i == 2) {
                    var x2 = secondSelectedSprite.bounds.x;
                    var y2 = secondSelectedSprite.bounds.y;
                    
                    secondSelectedSprite.transformationMatrix.translate( -x2, -y2);
                    secondSelectedSprite.transformationMatrix.translate(x3, y3);

                    var b = 0;
                    while (b < charButtonArray.length) {
                        if (charButtonArray[b].customData == 3) { 
                            charButtonArray[b].customData = 2; 
                            break;
                        }
                        b++;
                    }
                }
                
                if (i == 1) {
                    var x1 = firstSelectedSprite.bounds.x;
                    var y1 = firstSelectedSprite.bounds.y;                    
                    var x2 = secondSelectedSprite.bounds.x;
                    var y2 = secondSelectedSprite.bounds.y;
                
                    firstSelectedSprite.transformationMatrix.translate( -x1, -y1);
                    firstSelectedSprite.transformationMatrix.translate(x2, y2);  
                    secondSelectedSprite.transformationMatrix.translate( -x2, -y2);                                      
                    secondSelectedSprite.transformationMatrix.translate(x3, y3);
                    
                    var b = 0;
                    while (b < charButtonArray.length) {
                        if (charButtonArray[b].customData == 3) { 
                            charButtonArray[b].customData = 2; 
                        }
                        else if (charButtonArray[b].customData == 2) {
                            charButtonArray[b].customData = 1;
                        }
                        b++;
                    }
                }
                
                var b = 0;
                while (b < charButtonArray.length) {
                    if (!charButtonArray[b].enabled) { charButtonArray[b].enabled = true; }
                    b++;
                }
        }
    }
}