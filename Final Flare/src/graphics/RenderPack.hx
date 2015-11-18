package graphics;

import haxe.ds.StringMap;
import haxe.ds.ObjectMap;
import starling.textures.Texture;
import weapon.WeaponData;

// The rendering data used by a renderer for a level
class RenderPack {
    public var characters:SpriteSheet;
    public var enemies:SpriteSheet;
    public var projectiles:SpriteSheet;
    
    public var gun:SpriteSheet; // TODO: This needs to be a spritesheet and generated.
    public var weaponMapping:ObjectMap<WeaponData, String>; // Mapping of WeaponData to the generated sprites in the gun texture
    
    public var entityRenderData:StringMap<EntityRenderData>;
    
    // Level environment information
    public var environment:SpriteSheet;
    public var environmentDesaturated:SpriteSheet;
    public var tileAnimationSpeeds:Array<Int>;
    
    public var parallax:Array<Texture> = []; ///< Images of the different parallax layers
    
    // The background color when the screen is cleared to draw the level
    public var backgroundColor:UInt = 0x000000;
    
    public function new() {
        // Empty
    }
}