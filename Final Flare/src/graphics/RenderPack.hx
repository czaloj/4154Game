package graphics;

import starling.textures.Texture;

// The rendering data used by a renderer for a level
class RenderPack {
    public var characters:SpriteSheet;
    public var enemies:SpriteSheet;
    public var projectiles:SpriteSheet;
    public var environment:SpriteSheet;
    public var parallax:Array<Texture> = []; ///< Images of the different parallax layers

    // The background color when the screen is cleared to draw the level
    public var backgroundColor:UInt = 0x000000;
    
    public function new() {
        // Empty
    }
}