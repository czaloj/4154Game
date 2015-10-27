package graphics;

import starling.textures.Texture;

class SpriteSheetRegistry {  
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
