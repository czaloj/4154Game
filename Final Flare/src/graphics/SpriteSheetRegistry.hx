package graphics;

import starling.textures.Texture;

class SpriteSheetRegistry {  
    public static function getEnvironment(t:Texture, type:String):SpriteSheet {
        switch (type) {
            case "Simple":
                return new SpriteSheet(t, [
                    // TODO: Fill out with correct regions
                    new TileRegion("Half", 0, 0, 16, 16),
                    new TileRegion("Full", 16, 0, 32, 32)
                ]);
            case "Complex":
                return new SpriteSheet(t, [
                    // TODO: Fill out regions
                ]);
            default:
                return null;
        }
    }
    
    public function new() {
        // Empty
    }
}
