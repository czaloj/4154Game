package graphics;

import openfl.Lib;
import starling.display.Sprite;

class Renderer {
    private var hierarchy:RenderHierarchy = new RenderHierarchy();
    
    public function new(stage:Sprite) {
        // Everything will be rendered inside the hierarchy
        stage.addChild(hierarchy);
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
