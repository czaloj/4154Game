package;


import flash.net.FileReference;
import flash.events.Event;
import game.ColorScheme;
import game.GameLevel;
import game.GameState;
import game.Entity;
import game.MenuLevelModifiers;
import game.Region;
import game.Spawner;
import game.Platform;
import game.GameplayController;
import graphics.EntityRenderData;
import graphics.Renderer;
import graphics.RenderPack;
import graphics.SpriteSheet;
import graphics.SpriteSheetRegistry;
import graphics.StripRegion;
import graphics.TileRegion;
import haxe.ds.IntMap;
import haxe.ds.ObjectMap;
import haxe.ds.StringMap;
import haxe.Serializer;
import openfl.display.BitmapData;
import openfl.events.GameInputEvent;
import openfl.filters.ColorMatrixFilter;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import openfl.utils.ByteArray;
import starling.textures.Texture;
import openfl.Assets;
import haxe.Unserializer;
import weapon.WeaponData;
import weapon.WeaponGenerator;

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
        state.player = new Entity();
        state.player.position.set(level.playerPt.x, level.playerPt.y);
        state.regionLists = level.regionLists;
        state.regions = level.regions;
        state.nregions = level.nregions;
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
        renderPack.entityRenderData = new StringMap<EntityRenderData>();
        renderPack.entityRenderData.set("Grunt", new EntityRenderData("Grunt"));
        renderPack.entityRenderData.set("Tank", new EntityRenderData("Tank"));
        renderPack.entityRenderData.set("Shooter", new EntityRenderData("Shooter"));
        renderPack.entityRenderData.set("Man", new EntityRenderData("Man"));
        renderPack.entityRenderData.set("Wolf", new EntityRenderData("Wolf"));
        renderPack.entityRenderData.set("Robot", new EntityRenderData("Robot"));
        renderPack.entityRenderData.set("SteamGirl", new EntityRenderData("SteamGirl"));
        renderPack.entityRenderData.set("SandMan", new EntityRenderData("SandMan"));

        renderPack.enemies = new SpriteSheet(Texture.fromBitmapData(Assets.getBitmapData("assets/img/Enemies.png")), [
            new TileRegion("Grunt.Head", 69, 1, 12, 12),
            new StripRegion("Grunt.Rest", 0, 0, 34, 34, 1, 1, 1),
            new StripRegion("Grunt.Run", 0, 0, 34, 34, 1, 2, 2),
            new StripRegion("Grunt.Jump", 0, 0, 34, 34, 1, 2, 2),
            new TileRegion("Tank.Head", 35, 39, 22, 22),
            new StripRegion("Tank.Rest", 0, 36, 35, 35, 1, 1, 1),
            new StripRegion("Tank.Run", 0, 36, 35, 35, 1, 1, 1),
            new StripRegion("Tank.Jump", 0, 36, 35, 35, 1, 1, 1),
            new TileRegion("Shooter.Head", 35, 39, 22, 22),
            new StripRegion("Shooter.Rest", 0, 36, 35, 35, 1, 1, 1),
            new StripRegion("Shooter.Run", 0, 36, 35, 35, 1, 1, 1),
            new StripRegion("Shooter.Jump", 0, 36, 35, 35, 1, 1, 1)
        ]);
        renderPack.characters = SpriteSheetRegistry.getCharacterSheet();

        // Load parallax layers
        for (f in level.parallax) {
            renderPack.parallax.push(Texture.fromBitmapData(Assets.getBitmapData(f, false)));
        }

        //TODO: unhardcode
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

    public static function modifyFromMenu(mod:MenuLevelModifiers, state:game.GameState, renderPack:RenderPack):Void {
        // TODO: Create the entity array
        state.entities = [
            new Entity(),
            new Entity(),
            new Entity(),
            new Entity(),
            new Entity(),
        ];
        
        Spawner.createPlayer(state.entities[0], "Man", state.player.position.x, state.player.position.y);
        Spawner.createPlayer(state.entities[1], "Wolf", 0, 0);
        Spawner.createPlayer(state.entities[2], "Robot", 0, 0);
        Spawner.createPlayer(state.entities[3], "SteamGirl", 0, 0);
        Spawner.createPlayer(state.entities[4], "SandMan", 0, 0);

        // Disable all but the first character
        for (i in 1...5) {
            if (state.entities[i] != null) {
                state.entities[i].enabled = false;
            }
        }

        state.characterWeapons = mod.characterWeapons.copy();
        state.enemyWeapons = mod.enemyWeapons.copy();

        var bmpGuns:BitmapData = Assets.getBitmapData("assets/img/Gun.png");
        var bmpConvertedGuns:BitmapData = new BitmapData(bmpGuns.width, bmpGuns.height * 1);
        var cs:Array<ColorScheme> = [
            new ColorScheme(0xffff0000, 0xff00ff00, 0xff0000ff, 0, 0, 1, 1)
        ];
        var regions:Array<StripRegion> = [];
        for (i in 0...cs.length) {
            var nba:ByteArray = WeaponGenerator.convertColors(bmpGuns, new Rectangle(0, 0, bmpGuns.width, bmpGuns.height), cs[i]);
            bmpConvertedGuns.setPixels(new Rectangle(0, i * bmpGuns.height, bmpGuns.width, bmpGuns.height), nba);
            regions.push(new StripRegion("Gun" + Std.string(i), 0, i * bmpGuns.height, bmpGuns.width, bmpGuns.height, 1, 1, 1));
        }
        renderPack.gun = new SpriteSheet(Texture.fromBitmapData(bmpConvertedGuns), regions);
        renderPack.weaponMapping = new ObjectMap<WeaponData, String>();
        for (w in state.characterWeapons) renderPack.weaponMapping.set(w, "Gun0");
        for (w in state.enemyWeapons) renderPack.weaponMapping.set(w, "Gun0");
    }

    public function new() {
        // Empty
    }
}