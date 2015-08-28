package;

import openfl.events.MouseEvent;
import openfl.geom.Rectangle;
import openfl.Lib;
import starling.display.Sprite;
import starling.events.Event;
import starling.utils.AssetManager;
import starling.core.Starling;
import starling.display.Image;
import starling.textures.Texture;
import flash.display.BitmapData;

@:bitmap("assets/Sprites.png")
class TestImage extends BitmapData {
    public function new () {
        super(0, 0);
    }
}

class Game extends Sprite {
    var sheet:SpriteSheet;
    
    public function new() {
        super();
        
        addEventListener(Event.ADDED_TO_STAGE, load);
        openfl.Lib.current.stage.addEventListener(MouseEvent.CLICK, add);
    }
    
    private function load(e:Event = null):Void {
        var atlas:Texture = Texture.fromBitmapData(new TestImage());
        sheet = new SpriteSheet(atlas, [
            new SpriteStrip("Walking", 0, 0, 180, 250, 2, 5)
            ]);
        
        addChild(new Animated(sheet, "Walking"));
    }
    private function add(e:MouseEvent = null):Void {
        var a:Animated = new Animated(sheet, "Walking");
        a.x = e.stageX - a.width * 0.5;
        a.y = e.stageY - a.height * 0.5;
        addChild(a);
    }
    
}