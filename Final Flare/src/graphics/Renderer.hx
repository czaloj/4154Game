package graphics;

import openfl.Assets;
import openfl.events.Event;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import openfl.Lib;
import starling.core.Starling;
import starling.display.Sprite;
import starling.display.Stage;
import starling.textures.Texture;
import ui.UISpriteFactory;

class Renderer {
    private var stageHalfSize:Point = new Point();
    private var hierarchy:RenderHierarchy = new RenderHierarchy();
    private var pack:RenderPack;
    private var stage3D:Stage;
    
    public var cameraX(get,set):Float;
    public var cameraY(get,set):Float;
    public var cameraScale(get,set):Float;
    
    public function new(stage:Sprite, p:RenderPack) {
        pack = p;
        stage3D = stage.stage;

        // Everything will be rendered inside the hierarchy
        stage.stage.color = 0x808080;
        stage.addChild(hierarchy);
        onWindowResize(null);

        // Default camera
        cameraX = 0;
        cameraY = -16;
        cameraScale = 1;
        
        // What to do when screen changes size
        Lib.current.stage.addEventListener(Event.RESIZE, onWindowResize);
        
        // TODO: Remove this test code
        hierarchy.player.addChild(new AnimatedSprite(pack.characters, "Man.Run", 3));
        function fAdd(x:Float, y:Float, n:String):Void {
            var brick:StaticSprite = new StaticSprite(pack.environment, n);
            brick.x = x;
            brick.y = y;
            hierarchy.foreground.addChild(brick);            
        };
        for (i in 0...10) {
            fAdd(i * pack.environment.getTile("Brick").width, -16, "Brick");
        }
        fAdd( -32, 0, "PurpleMetal");
        fAdd( -32, -32, "PurpleMetal");
        

        var uif:UISpriteFactory = new UISpriteFactory(Texture.fromBitmapData(Assets.getBitmapData("assets/img/UI.png")));
        var hb:StaticSprite = uif.getTile("Health.Background");
        hb.scaleX *= 2;
        hb.scaleY *= 2;
        stage3D.addChild(hb);
    
    }
    public function get_cameraX():Float {
        return hierarchy.origin.x;
    }
    public function set_cameraX(v:Float):Float {
        hierarchy.origin.x = v;
        return v;
    }
    public function get_cameraY():Float {
        return -hierarchy.origin.y;
    }
    public function set_cameraY(v:Float):Float {
        hierarchy.origin.y = -v;
        return v;
    }
    public function get_cameraScale():Float {
        return hierarchy.camera.scaleX;
    }
    public function set_cameraScale(v:Float):Float {
        hierarchy.camera.scaleX = v;
        hierarchy.camera.scaleY = -v;
        return v;
    }
    
    private function onWindowResize(o:Event = null):Void {
        // Recenter the camera
        stageHalfSize.x = Lib.current.stage.stageWidth / 2;
        stageHalfSize.y = Lib.current.stage.stageHeight / 2;
        hierarchy.camera.x = stageHalfSize.x;
        hierarchy.camera.y = stageHalfSize.y;
        
        // Resize viewport
        stage3D.stageWidth = Lib.current.stage.stageWidth;
        stage3D.stageHeight = Lib.current.stage.stageHeight;
        var viewPortRectangle:Rectangle = new Rectangle(0, 0, stage3D.stageWidth, stage3D.stageHeight);
        Starling.current.viewPort = viewPortRectangle;
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
