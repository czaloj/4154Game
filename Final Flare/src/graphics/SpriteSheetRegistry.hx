package graphics;

import starling.textures.Texture;

class SpriteSheetRegistry {
    public static inline var TYPE_CITY:String = "City";
    public static inline var TYPE_SEWER:String = "Sewer";
    public static inline var TYPE_FACTORY:String = "Factory";
    public static inline var TYPE_INVADERS:String = "Invaders";
    public static inline var TILE_ID_FIRST_ANIMATION:Int = 19;
    
    public static function getSheetName(id:Int) {
        switch (id) {
            case 1: return "FloorFull.0";
            case 2: return "FloorFull.1";
            case 3: return "FloorFull.2";
            case 4: return "FloorDetail.0";
            case 5: return "FloorDetail.1";
            case 6: return "Fill";
            case 7: return "Supports.0";
            case 8: return "Supports.1";
            case 9: return "Framing";
            case 10: return "SmallBox.0";
            case 11: return "SmallBox.1";
            case 12: return "SmallBox.2";
            case 13: return "SmallBox.3";
            case 14: return "LargeBox.0";
            case 15: return "LargeBox.1";
            case 16: return "LargeBox.2";
            case 17: return "LargeBox.3";
            case 18: return "LargeBox.4";
            case 19: return "SmallContainer.0";
            case 20: return "SmallContainer.1";
            case 21: return "SmallContainer.2";
            case 22: return "SmallContainer.3";
            case 23: return "LargeContainer.0";
            case 24: return "LargeContainer.1";
            case 25: return "LargeContainer.2";
            case 26: return "LargeContainer.3";
            case 27: return "LargeContainer.4";
            default: return "";
        }
    }
    // TODO: Remove this for a better data structure
    public static function isHalfTile(id:Int):Bool {
        switch (id) {
            case 4, 5, 9, 10, 11, 12, 13, 19, 20, 21, 22:
                return true;
            default:
                return false;
        }
    }
    
    public static function getEnvironment(t:Texture, type:String):SpriteSheet {
        var animationData:Array<Int> = null;
        switch(type) {
            case TYPE_CITY:
                animationData = [
                    // Half containers
                    2, 2, 2, 2,
                    // Full containers
                    2, 2, 2, 2, 2
                    ];
            case TYPE_SEWER:
                animationData = [
                    // Half containers
                    2, 2, 2, 2,
                    // Full containers
                    2, 2, 2, 2, 2
                    ];
            case TYPE_FACTORY:
                animationData = [
                    // Half containers
                    2, 2, 2, 2,
                    // Full containers
                    2, 2, 2, 2, 2
                    ];
            case TYPE_INVADERS:
                animationData = [
                    // Half containers
                    2, 2, 2, 2,
                    // Full containers
                    2, 2, 2, 2, 2
                    ];
        }
        
        var f:Int = 2;
        return new SpriteSheet(t, [
            // TODO: Fill out with correct regions
            new ConnectedRegion("FloorFull.0", 0, 0, 32, 32),
            new ConnectedRegion("FloorFull.1", 384, 0, 32, 32),
            new ConnectedRegion("FloorFull.2", 0, 128, 32, 32),
            new ConnectedRegion("FloorDetail.0", 768, 0, 16, 16),
            new ConnectedRegion("FloorDetail.1", 768, 64, 16, 16),
            new ConnectedRegion("Fill", 384, 128, 32, 32),
            new ConnectedRegion("Supports.0", 0, 256, 32, 32),
            new ConnectedRegion("Supports.1", 384, 256, 32, 32),
            new ConnectedRegion("Framing", 768, 128, 16, 16),
            new TileRegion("SmallBox.0", 768, 192, 16, 16),
            new TileRegion("SmallBox.1", 768 + 16, 192, 16, 16),
            new TileRegion("SmallBox.2", 768 + 32, 192, 16, 16),
            new TileRegion("SmallBox.3", 768 + 48, 192, 16, 16),
            new TileRegion("LargeBox.0", 0, 384, 32, 32),
            new TileRegion("LargeBox.1", 32, 384, 32, 32),
            new TileRegion("LargeBox.2", 64, 384, 32, 32),
            new TileRegion("LargeBox.3", 96, 384, 32, 32),
            new TileRegion("LargeBox.4", 128, 384, 32, 32),
            new StripRegion("SmallContainer.0", 768, 208, 16, 16, 1, animationData[0], animationData[0]),
            new StripRegion("SmallContainer.1", 768, 224, 16, 16, 1, animationData[1], animationData[1]),
            new StripRegion("SmallContainer.2", 768, 240, 16, 16, 1, animationData[2], animationData[2]),
            new StripRegion("SmallContainer.3", 768, 256, 16, 16, 1, animationData[3], animationData[3]),
            new StripRegion("LargeContainer.0", 0, 416, 32, 32, 1, animationData[4], animationData[4]),
            new StripRegion("LargeContainer.1", 0, 448, 32, 32, 1, animationData[5], animationData[5]),
            new StripRegion("LargeContainer.2", 0, 480, 32, 32, 1, animationData[6], animationData[6]),
            new StripRegion("LargeContainer.3", 0, 512, 32, 32, 1, animationData[7], animationData[7]),
            new StripRegion("LargeContainer.4", 0, 544, 32, 32, 1, animationData[8], animationData[8])
        ]);
    }
    public static function getAnimationSpeeds(type:String):Array<Int> {
        switch(type) {
            case TYPE_CITY:
                return [
                    // Half containers
                    15, 15, 15, 15,
                    // Full containers
                    15, 15, 15, 15, 15
                    ];
            case TYPE_SEWER:
                return [
                    // Half containers
                    15, 15, 15, 15,
                    // Full containers
                    15, 15, 15, 15, 15
                    ];
            case TYPE_FACTORY:
                return [
                    // Half containers
                    15, 15, 15, 15,
                    // Full containers
                    15, 15, 15, 15, 15
                    ];
            case TYPE_INVADERS:
                return [
                    // Half containers
                    15, 15, 15, 15,
                    // Full containers
                    15, 15, 15, 15, 15
                    ];
            default:
                return null;
        }
    }
    
    public function new() {
        // Empty
    }
}
