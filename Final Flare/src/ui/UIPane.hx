package ui;

import starling.display.DisplayObjectContainer;

class UIPane extends DisplayObjectContainer {

    public function new() {
        super();
    }
    
    
    public function add(object:DisplayObjectContainer, tx:Float = 0, ty:Float = 0) {
        object.transformationMatrix.translate(tx, ty);
        this.addChild(object);
        
    }
}