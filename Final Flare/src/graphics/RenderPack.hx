package graphics;

import starling.textures.Texture;

// The rendering data used by a renderer for a level
class RenderPack {
    public var characters:SpriteSheet;
    public var enemies:SpriteSheet;

    public var environment:SpriteSheet;
    public var parallax:Array<Texture> = []; ///< Images of the different parallax layers

    public function new() {
        // Empty
    }
}