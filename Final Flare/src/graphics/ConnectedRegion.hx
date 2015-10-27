package graphics;

import starling.display.Image;

class ConnectedRegion extends StripRegion {
    private static function mapNeighbors(disconnected:Int):Int {
        switch(disconnected) {
            case 0x00: return 26;
            case 0x02: return 33;
            case 0x08: return 32;
            case 0x0A: return 11;
            case 0x0E: return 38;
            case 0x20: return 44;
            case 0x22: return 35;
            case 0x28: return 10;
            case 0x2A: return 20;
            case 0x2E: return 42;
            case 0x38: return 27;
            case 0x3A: return 41;
            case 0x3E: return 39;
            case 0x80: return 45;
            case 0x82: return 23;
            case 0x83: return 25;
            case 0x88: return 34;
            case 0x8A: return 8;
            case 0x8B: return 30;
            case 0x8E: return 40;
            case 0x8F: return 37;
            case 0xA0: return 22;
            case 0xA2: return 9;
            case 0xA3: return 28;
            case 0xA8: return 21;
            case 0xAA: return 46;
            case 0xAB: return 6;
            case 0xAE: return 18;
            case 0xAF: return 16;
            case 0xB8: return 43;
            case 0xBA: return 19;
            case 0xBB: return 24;
            case 0xBE: return 17;
            case 0xBF: return 36;
            case 0xE0: return 14;
            case 0xE2: return 31;
            case 0xE3: return 13;
            case 0xE8: return 29;
            case 0xEA: return 7;
            case 0xEB: return 4;
            case 0xEE: return 2;
            case 0xEF: return 1;
            case 0xF8: return 15;
            case 0xFA: return 5;
            case 0xFB: return 12;
            case 0xFE: return 3;
            case 0xFF: return 0;
            default: return 0;
        }
    }
    
    /**
     * @param name: Name of the strip within the sprite sheet
     * @param sx: Pixel X starting location
     * @param sy: Pixel Y starting location
     * @param w: Width of a single piece in pixels
     * @param h: Height of a single piece in pixels
     */
    public function new(name:String, sx:Int, sy:Int, w:Int, h:Int) {
        super(name, sx, sy, w, h, 4, 12, 47);
    }
    
    public function setToTile(i:Image, neighbors:Int, flipTexture:Bool) {
        setToFrame(i, mapNeighbors(neighbors ^ 0xff), flipTexture);
    }
}
