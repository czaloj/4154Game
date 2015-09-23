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
import starling.display.Quad;
import starling.textures.Texture;
import flash.display.BitmapData;

class ScreenController extends Sprite
{
    public static var FRAME_TIME:Float = 1.0 / 60.0;

    public var sheet:SpriteSheet;
    public var dt:GameTime;

    private var screens:Array<IGameScreen>; 
    private var activeScreen:IGameScreen;

    public function new()
    {
        super();

        addEventListener(Event.ADDED_TO_STAGE, load);
        openfl.Lib.current.stage.addEventListener(MouseEvent.CLICK, add);
        openfl.Lib.current.stage.addEventListener(Event.ENTER_FRAME, update);
        dt = new GameTime();

        // Start on the splash screen
        screens = [
            new GameplayScreen(this)
        ];
        activeScreen = screens[0];
    }

    private function randomAnimation():Animated
    {
        switch(Std.int(Math.random() * 3.0)) {
        case 0:
            return new Animated(sheet, "Walking", 4);
        case 1:
            return new Animated(sheet, "Backflip", 2);
        default:
            return new Animated(sheet, "Idle", 5);
        }
    }

    private function load(e:Event = null):Void
    {
        sheet = new SpriteSheet(Texture.fromBitmapData(Assets.getBitmapData("assets/img/Man.png")), [
            new SpriteStrip("Backflip", 0, 0, 48, 90, 2, 42, 80),
            new SpriteStrip("Walking", 0, 180, 48, 90, 1, 12, 12),
            new SpriteStrip("Idle", 0, 270, 48, 90, 1, 7, 7)
            ]);

        var a:Animated = new Animated(sheet, "Walking", 4);

        addChild(a);
        
        for(screen in screens) screen.build();
        activeScreen.onEntry(dt);
    }

    private function add(e:MouseEvent = null):Void
    {
        var a:Animated = randomAnimation();
        a.x = e.stageX - a.width * 0.5;
        a.y = e.stageY - a.height * 0.5;
        addChild(a);
    }

    private function update(e:Dynamic = null):Void {
        dt.elapsed = FRAME_TIME;
        dt.total += dt.elapsed;
        dt.frame++;
        
        activeScreen.update(dt);
        activeScreen.draw(dt);
    }

}