package ui;

import starling.display.DisplayObject;
import starling.display.DisplayObjectContainer;

class UIPane extends DisplayObjectContainer {

    public function new() {
        super();
    }
    
    public function add(object:DisplayObject, tx:Float = 0, ty:Float = 0) {
        object.transformationMatrix.translate(tx, ty);
        this.addChild(object);
    }
}