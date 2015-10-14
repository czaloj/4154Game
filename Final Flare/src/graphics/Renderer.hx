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
        var newSprite:Sprite = new Sprite();
        sprites.push(newSprite);
        stage3D.addChild(newSprite);

        // Add a corresponding sprite to stage and track this entity

        //what sprite gets added? where is this function called? should this be called "addEntitySprite" instead of onEntityAdded?
    }
    public function onEntityRemoved(o:ObjectModel):Void {
        //idk about this function the implementation i was thinking of was sketchy.
        //i need to figure out the mapping between objectModels and sprites

        // Remove this entity from the stage
    }

    public function update(s:GameState):Void {
        var levelHalfWidth = s.width * TILE_HALF_WIDTH / 2;
        var levelHalfHeight = s.height * TILE_HALF_WIDTH / 2;
        // Update sprite positions from entities
        hierarchy.player.x = s.player.body.getPosition().x;
        hierarchy.player.y = s.player.body.getPosition().y;
        set_cameraX(Math.min(levelHalfWidth - Lib.current.stage.stageWidth / 2, Math.max(-levelHalfWidth + Lib.current.stage.stageWidth / 2, -hierarchy.player.x)));
        set_cameraY(Math.min(levelHalfHeight - Lib.current.stage.stageHeight / 2, Math.max(-levelHalfHeight + Lib.current.stage.stageHeight / 2, hierarchy.player.y)));
        var count:Int = 0;
        for (i in s.entities) {
            count++;
            sprites[count].x = i.position.x;
            sprites[count].y = i.position.y;
        }

        // Update parallax layers
        // TODO: Compute camera ratio in level
        var rx:Float = crX;
        var ry:Float = crY;
        for (layer in hierarchy.parallax.children) {
            var pLayer:ParallaxSprite = cast (layer, ParallaxSprite);
            pLayer.update(rx, ry);
        }
    }

    private function load(state:GameState):Void {
        // TODO: Remove this test code
        var man = new AnimatedSprite(pack.characters, "Man.Run", 3);
        man.x = state.player.position.x - 32;
        man.y = state.player.position.y + 64;
        hierarchy.player.addChild(man);
        function fAdd(x:Float, y:Float, n:String):Void {
            var brick:StaticSprite = new StaticSprite(pack.environment, n);
            brick.x = x;
            brick.y = y;
            hierarchy.foreground.addChild(brick);
        };
        for (i in 0...state.foreground.length) {
            var x:Float = (i % state.width) * TILE_HALF_WIDTH - state.width * TILE_HALF_WIDTH * 0.5;
            var y:Float = (state.height -  (Std.int(i / state.width) + 1)) * TILE_HALF_WIDTH - state.height * TILE_HALF_WIDTH * 0.5;
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
