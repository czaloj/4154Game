package;

import graphics.RenderPack;
import graphics.SpriteSheet;
import graphics.SpriteSheetRegistry;
import graphics.StripRegion;
import graphics.TileRegion;
import haxe.ds.StringMap;
import starling.textures.Texture;
import openfl.Assets;

class LevelCreator {
    public static function createFromFile(file:String, state:GameState, renderPack:RenderPack):Void {
        var value = Assets.getText(file);
        var level = haxe.Unserializer.run(value);
        createFromLevel(level, state, renderPack);
    }

    public static function createFromLevel(level:GameLevel, state:GameState, renderPack:RenderPack):Void {
        state.width = level.width;
        state.height = level.height;
        state.foreground = level.foreground; // TODO: Better data structure
        state.background = level.background; // TODO: Better data structure
        state.spawners = level.spawners;
        state.player.position.setTo(level.playerPt.x, level.playerPt.y);
        
        // Load the environment texture
        var environmentTexture:Texture = Texture.fromBitmapData(Assets.getBitmapData(level.environmentSprites, false));
        renderPack.environment = SpriteSheetRegistry.getEnvironment(environmentTexture, level.environmentType);
        
        // TODO: Load/stitch enemies from spawner information
        renderPack.enemies = new SpriteSheet(Texture.fromBitmapData(Assets.getBitmapData("assets/img/Pixel.png", false)), [
            // TODO: Add hardcoded enemies
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
    
    public function new() {
        // Empty
    }
}