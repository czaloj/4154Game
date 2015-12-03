package ui;

import openfl.display.DisplayObject;
import openfl.display.DisplayObjectContainer;
import openfl.display.Sprite;
import openfl.text.TextField;

class ShopPane extends Sprite {

    public function new() {
        super();
    }
    
    public function add(object:Sprite, tx:Float = 0, ty:Float = 0) {
        object.transform.matrix.translate(tx, ty);
        this.addChild(object);
    }
}