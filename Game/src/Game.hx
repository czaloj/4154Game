package;

import openfl.Assets;
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

class Game extends Sprite {
    var sheet:SpriteSheet;
    
    public function new() {
        super();
        
        addEventListener(Event.ADDED_TO_STAGE, load);
        openfl.Lib.current.stage.addEventListener(MouseEvent.CLICK, add);
    }
    
    private function randomAnimation():String {
        switch(Std.int(Math.random() * 2.0)) {
        case 0:
            return "Walking";
        default:
            return "Idle";
        }
    }
    
    private function load(e:Event = null):Void {
        sheet = new SpriteSheet(Texture.fromBitmapData(Assets.getBitmapData("assets/Man.png")), [
            new SpriteStrip("Walking", 0, 0, 48, 90, 1, 12, 12),
            new SpriteStrip("Idle", 0, 90, 48, 90, 1, 7, 7)
            ]);
        
        addChild(new Animated(sheet, randomAnimation(), 3));
    }
    private function add(e:MouseEvent = null):Void {
        var a:Animated = new Animated(sheet, randomAnimation(), 3);
        a.x = e.stageX - a.width * 0.5;
        a.y = e.stageY - a.height * 0.5;
        addChild(a);
    }
    
}