package graphics;

import openfl.Assets;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import openfl.Lib;
import starling.core.Starling;
import starling.display.Image;
import starling.display.Sprite;
import starling.display.Stage;
import starling.textures.Texture;

class Renderer {
    public static inline var TILE_HALF_WIDTH:Float = 16;
    public static inline var PLAYER_WIDTH:Float = 32;
    public static inline var PLAYER_HEIGHT:Float = 64;

    private var stageHalfSize:Point = new Point();
    private var hierarchy:RenderHierarchy = new RenderHierarchy();
    private var pack:RenderPack;
    private var stage3D:Stage;
    //private var myState:GameState;
    public var sprites:Array<Sprite> = [];

    public var cameraX(get,set):Float;
    public var cameraY(get,set):Float;
    public var cameraScale(get,set):Float;

    private var crX:Float;
    private var crY:Float;

    public function new(stage:Sprite, p:RenderPack, state:GameState) {
        pack = p;
        stage3D = stage.stage;

        //myState = state;
        // Everything will be rendered inside the hierarchy
        stage.stage.color = 0x808080;
        stage.addChild(hierarchy);
        onWindowResize(null);

        // Default camera
        cameraX = 0;
        cameraY = 0;
        cameraScale = 1;

        // What to do when screen changes size
        Lib.current.stage.addEventListener(Event.RESIZE, onWindowResize);
        Lib.current.stage.addEventListener(MouseEvent.MOUSE_MOVE, function (e:MouseEvent = null):Void {
            crX = e.stageX / ScreenController.SCREEN_WIDTH;
            crY = e.stageY / ScreenController.SCREEN_HEIGHT;
        });

        load(state);
    }

    public function get_cameraX():Float {
        return -hierarchy.origin.x;
    }
    public function set_cameraX(v:Float):Float {
        hierarchy.origin.x = -v;
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

        //what sprite gets added? where is this function called? should this be called "addEntitySprite" instead of onEntityAdded?
    }
    public function onEntityRemoved(o:ObjectModel):Void {
        //idk about this function the implementation i was thinking of was sketchy.
        //i need to figure out the mapping between objectModels and sprites

        // Remove this entity from the stage
    }

    public function update(s:GameState):Void {
        // TODO: Update sprite positions from entities
        var count:Int = 0;
        for (i in s.entities) {
            count++;
            sprites[count].x = i.position.x;
            sprites[count].y = i.position.y;
        }

        // Center camera on player and constrict to level bounds
        var levelWidth = s.width * TILE_HALF_WIDTH;
        var levelHeight = s.height * TILE_HALF_WIDTH;
        var cameraHalfWidth = stage3D.stageWidth / (2 * cameraScale);
        var cameraHalfHeight = stage3D.stageHeight / (2 * cameraScale);
        cameraX = Math.min((levelWidth) - cameraHalfWidth, Math.max((0) + cameraHalfWidth, s.player.position.x));
        cameraY = Math.min((levelHeight) - cameraHalfHeight, Math.max((0) + cameraHalfHeight, s.player.position.y));

        // Update parallax layers
        crX = (cameraX - cameraHalfWidth) / (levelWidth - 2 * cameraHalfWidth);
        crY = (cameraY - cameraHalfHeight) / (levelHeight - 2 * cameraHalfHeight);
        for (layer in hierarchy.parallax.children) {
            var pLayer:ParallaxSprite = cast (layer, ParallaxSprite);
            pLayer.update(crX, crY);
        }
    }

    private function load(state:GameState):Void {
        // TODO: Remove this test code
        var man = new AnimatedSprite(pack.characters, "Man.Run", 3);
        //TODO: remove magic number: player dimension
        man.x = state.player.position.x - PLAYER_WIDTH * 0.5;
        man.y = state.player.position.y - PLAYER_HEIGHT * 0.5;
        hierarchy.player.addChild(man);
        function fAdd(x:Float, y:Float, n:String):Void {
            var brick:StaticSprite = new StaticSprite(pack.environment, n);
            brick.x = x;
            brick.y = y;
            hierarchy.foreground.addChild(brick);
        };
        for (i in 0...state.foreground.length) {
            var x:Float = (i % state.width) * TILE_HALF_WIDTH;
            var y:Float = (state.height -  (Std.int(i / state.width) + 1)) * TILE_HALF_WIDTH;
            if (state.foreground[i] == 1) {
                fAdd(x, y, "Half");
            }
            if (state.foreground[i] == 2) {
                // TODO: This why it won't work quite yet... need better data structure
                fAdd(x, y, "Full");
            }
        }

        // Add the parallax layers in a sorted order by their width
        pack.parallax.sort(function (t1:Texture, t2:Texture):Int {
            if (t1.width == t2.width) return 0;
            else if (t1.width < t2.width) return -1;
            else return 1;
        });
        for (texture in pack.parallax) {
            hierarchy.parallax.addChild(new ParallaxSprite(texture, state.width * TILE_HALF_WIDTH, state.height * TILE_HALF_WIDTH, ScreenController.SCREEN_WIDTH, ScreenController.SCREEN_HEIGHT));
        }
    }
}
