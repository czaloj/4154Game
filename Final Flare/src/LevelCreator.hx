package;

import flash.net.FileReference;
import flash.events.Event;
import game.GameLevel;
import game.GameState;
import game.Entity;
import game.MenuLevelModifiers;
import game.Spawner;
import game.Platform;
import graphics.EntityRenderData;
import graphics.Renderer;
import graphics.RenderPack;
import graphics.SpriteSheet;
import graphics.SpriteSheetRegistry;
import graphics.StripRegion;
import graphics.TileRegion;
import haxe.ds.ObjectMap;
import haxe.ds.StringMap;
import haxe.Serializer;
import openfl.display.BitmapData;
import openfl.events.GameInputEvent;
import openfl.filters.ColorMatrixFilter;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import starling.textures.Texture;
import openfl.Assets;
import haxe.Unserializer;

class LevelCreator {
    public static function saveToFile(lvl:game.GameLevel):Void {
        var fileRef:FileReference = new FileReference();
        fileRef.addEventListener(Event.COMPLETE, function (e:Event = null):Void {
            trace("Save Successful");
        });
        fileRef.save(Serializer.run(lvl),"level.txt");
    }
    public static function loadLevelFromFile(file:String):game.GameLevel {
        var value = Assets.getText(file);
        var level:game.GameLevel = cast(Unserializer.run(value), game.GameLevel);
        return level;
    }

    public static function createStateFromLevel(level:game.GameLevel, state:game.GameState):Void {
        state.width = level.width;
        state.height = level.height;
        state.foreground = level.foreground; // TODO: Better data structure
        state.background = level.background; // TODO: Better data structure
        state.spawners = level.spawners;
        state.platforms = Platform.createFromTileMap(state.width, state.height, state.foreground);
        
        // Create the entity array
        state.entities = [
            new Entity(),
            new Entity(),
            new Entity(),
            new Entity(),
            null
        ];
        for (i in 0...5) {
            if (state.entities[i] != null) {
                Spawner.createPlayer(state.entities[i], "player", level.playerPt.x, level.playerPt.y);
            }
        }
    }
    public static function createPackFromLevel(level:game.GameLevel, renderPack:RenderPack):Void {
        // Load the environment texture
        var bmpEnv:BitmapData = Assets.getBitmapData(level.environmentSprites, false);
        renderPack.environment = SpriteSheetRegistry.getEnvironment(Texture.fromBitmapData(bmpEnv), level.environmentType);
        var bmpEnvDesaturated:BitmapData = new BitmapData(bmpEnv.width, bmpEnv.height);
        var s1:Float = 1.0 - 2 * (Renderer.DESATURATION_LEVEL) / 3.0;
        var s2:Float = Renderer.DESATURATION_LEVEL / 3;
        bmpEnvDesaturated.applyFilter(bmpEnv, new Rectangle(0, 0, bmpEnv.width, bmpEnv.height), new Point(0, 0), new ColorMatrixFilter([
            s1, s2, s2, 0, 0,
            s2, s1, s2, 0, 0,
            s2, s2, s1, 0, 0,
            0, 0, 0, 1, 0
        ]));
        renderPack.environmentDesaturated = SpriteSheetRegistry.getEnvironment(Texture.fromBitmapData(bmpEnvDesaturated), level.environmentType);
        renderPack.tileAnimationSpeeds = SpriteSheetRegistry.getAnimationSpeeds(level.environmentType);

        // TODO: Load/stitch enemies from spawner information
        renderPack.enemies = new SpriteSheet(Texture.fromBitmapData(Assets.getBitmapData("assets/img/Pixel.png", false)), [
            // TODO: Add hardcoded enemies
        ]);
        renderPack.entityRenderData = new ObjectMap<String, EntityRenderData>();
        renderPack.entityRenderData.set("Robot", new EntityRenderData("Robot"));
        renderPack.entityRenderData.set("Man", new EntityRenderData("Man"));

        renderPack.enemies = new SpriteSheet(Texture.fromBitmapData(Assets.getBitmapData("assets/img/Robot.png")), [
            new TileRegion("Robot.Head", 8, 2, 20, 20),
            new StripRegion("Robot.Rest", 0, 0, 36, 64, 1, 10, 10),
            new StripRegion("Robot.Run", 0, 0, 36, 64, 1, 10, 10),
            new StripRegion("Robot.Jump", 0, 0, 36, 64, 1, 10, 10),
            new StripRegion("Robot.Death", 0, 0, 36, 64, 1, 10, 10)
        ]);

        // Load parallax layers
        for (f in level.parallax) {
            renderPack.parallax.push(Texture.fromBitmapData(Assets.getBitmapData(f, false)));
        }

        //TODO: unhardcode
        renderPack.characters = new SpriteSheet(Texture.fromBitmapData(Assets.getBitmapData("assets/img/Man.png")), [
            new TileRegion("Man.Head", 12, 2, 24, 24),
            new StripRegion("Man.Rest", 0, 270, 48, 90, 1, 7, 7),
            new StripRegion("Man.Run", 0, 180, 48, 90, 1, 12, 12),
            new StripRegion("Man.Jump", 0, 0, 48, 90, 2, 42, 80),
            new StripRegion("Man.Death", 0, 0, 48, 90, 2, 42, 80)
        ]);
        renderPack.projectiles = new SpriteSheet(Texture.fromBitmapData(Assets.getBitmapData("assets/img/Bullet.png")), [
            new StripRegion("Bullet.Fly", 0, 0, 5, 10, 1, 1, 1)
        ]);
    }
    
    public static function createStateFromFile(file:String, state:game.GameState):Void {
        createStateFromLevel(loadLevelFromFile(file), state);
    }
    public static function createPackFromFile(file:String, renderPack:RenderPack):Void {
        createPackFromLevel(loadLevelFromFile(file), renderPack);
    }

    public static function modifyFromMenu(mod:MenuLevelModifiers, state:game.GameState):Void {
        state.characterWeapons = mod.characterWeapons.copy();
        state.enemyWeapons = mod.enemyWeapons.copy();
    }
    
    public function new() {
        // Empty
    }
}