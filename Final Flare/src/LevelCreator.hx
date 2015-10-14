package;

import flash.net.FileReference;
import flash.events.Event;
import graphics.RenderPack;
import graphics.SpriteSheet;
import graphics.SpriteSheetRegistry;
import graphics.StripRegion;
import graphics.TileRegion;
import haxe.ds.StringMap;
import haxe.Serializer;
import openfl.events.GameInputEvent;
import starling.textures.Texture;
import openfl.Assets;
import haxe.Unserializer;

class LevelCreator {
    public static function saveToFile(lvl:GameLevel):Void {
        var fileRef:FileReference = new FileReference();
        fileRef.addEventListener(Event.COMPLETE, function (e:Event = null):Void {
            trace("Save Successful");
        });
        fileRef.save(Serializer.run(lvl),"level.txt");
    }
    public static function loadLevelFromFile(file:String):GameLevel {
        var value = Assets.getText(file);
        var level:GameLevel = cast(Unserializer.run(value), GameLevel);
        return level;
    }
    
    public static function createStateFromLevel(level:GameLevel, state:GameState):Void {
        state.width = level.width;
        state.height = level.height;
        state.foreground = level.foreground; // TODO: Better data structure
        state.background = level.background; // TODO: Better data structure
        state.spawners = level.spawners;
        
        state.player = new ObjectModel();
        state.player.position.set(level.playerPt.x, level.playerPt.y);
    }
    public static function createPackFromLevel(level:GameLevel, renderPack:RenderPack):Void {
        // Load the environment texture
        var environmentTexture:Texture = Texture.fromBitmapData(Assets.getBitmapData(level.environmentSprites, false));
        renderPack.environment = SpriteSheetRegistry.getEnvironment(environmentTexture, level.environmentType);

        // TODO: Load/stitch enemies from spawner information
        renderPack.enemies = new SpriteSheet(Texture.fromBitmapData(Assets.getBitmapData("assets/img/Pixel.png", false)), [
            // TODO: Add hardcoded enemies
        ]);

        renderPack.enemies = new SpriteSheet(Texture.fromBitmapData(Assets.getBitmapData("assets/img/Robot.png")), [
            new StripRegion("Robot.Run", 0, 0, 36, 64, 1, 10, 10),
        ]);

        // Load parallax layers
        for (f in level.parallax) {
            renderPack.parallax.push(Texture.fromBitmapData(Assets.getBitmapData(f, false)));
        }

        //TODO: unhardcode
        renderPack.characters = new SpriteSheet(Texture.fromBitmapData(Assets.getBitmapData("assets/img/Man.png")), [
            new StripRegion("Man.Backflip", 0, 0, 48, 90, 2, 42, 80),
            new StripRegion("Man.Run", 0, 180, 48, 90, 1, 12, 12),
            new StripRegion("Man.Idle", 0, 270, 48, 90, 1, 7, 7)
        ]);
    }

    public static function createStateFromFile(file:String, state:GameState):Void {
        createStateFromLevel(loadLevelFromFile(file), state);
    }
    public static function createPackFromFile(file:String, renderPack:RenderPack):Void {
        createPackFromLevel(loadLevelFromFile(file), renderPack);
    }

    public function new() {
        // Empty
    }
}