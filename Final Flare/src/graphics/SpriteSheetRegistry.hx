package graphics;

import starling.textures.Texture;

class SpriteSheetRegistry {  
    public static function getEnvironment(t:Texture, type:String):SpriteSheet {
        switch (type) {
            case "Simple":
                return new SpriteSheet(t, [
                    // TODO: Fill out regions
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
