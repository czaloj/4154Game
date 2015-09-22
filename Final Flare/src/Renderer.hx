package;

import openfl.Lib;
import starling.display.DisplayObject;

class Renderer {
    public function new(stage:DisplayObject) {
        // Empty
    }
    
    public function onEntityAdded(o:ObjectModel):Void {
        // Add a corresponding sprite to stage and track this entity
    }
    public function onEntityRemoved(o:ObjectModel):Void {
        // Remove this entity from the stage
    }
    
    public function update():Void {
        // Update sprite positions from entities
    }
}

