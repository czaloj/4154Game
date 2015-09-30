package;
import graphics.RenderPack;
import graphics.SpriteSheet;
import graphics.StripRegion;
import graphics.TileRegion;
import starling.textures.Texture;
import openfl.Assets;

/**
 * ...
 * @author Sophie Huang
 */
class LevelCreator
{

    public function new()
    {
    }

    public static function createFromFile(file:String, state:GameState, renderPack:RenderPack):Void {
        var value = Assets.getText(file);
        var level = haxe.Unserializer.run(value);
        createFromLevel(level, state, renderPack);

    }

    public static function createFromLevel(level:GameLevel, state:GameState, renderPack:RenderPack):Void {
        state.width = level.width;
        state.height = level.height;
        state.foreground = level.foreground;
        state.background = level.background;
        state.spawners = level.spawners;
        state.player.position = level.playerPt;

        renderPack.environment = level.environmentSprites;
        renderPack.enemies = level.enemiesSprites;
        renderPack.parallax = level.parallax;

        //TODO: unhardcode
        renderPack.characters = new SpriteSheet(Texture.fromBitmapData(Assets.getBitmapData("assets/img/Man.png")), [
            new StripRegion("Man.Backflip", 0, 0, 48, 90, 2, 42, 80),
            new StripRegion("Man.Run", 0, 180, 48, 90, 1, 12, 12),
            new StripRegion("Man.Idle", 0, 270, 48, 90, 1, 7, 7)
        ]);
        renderPack.environment = new SpriteSheet(Texture.fromBitmapData(Assets.getBitmapData("assets/img/Factory.png")), [
            new TileRegion("Brick", 0, 0, 16, 16),
            new TileRegion("PurpleMetal", 16, 0, 32, 32)
        ]);
    }

}