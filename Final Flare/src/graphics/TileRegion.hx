package graphics;

import starling.display.Image;

class TileRegion {
    // Name of the tile
    public var name:String;

    // Strip pixel information 
    private var sourceX:Int;
    private var sourceY:Int;
    public var width:Int;
    public var height:Int;
    
    // UV-space information
    private var xMin:Float;
    private var xMax:Float;
    private var yMin:Float;
    private var yMax:Float;
    
    /**
     * @param name: Name of the strip within the sprite sheet
     * @param sx: Pixel X starting location
     * @param sy: Pixel Y starting location
     * @param w: Width of a single piece in pixels
     * @param h: Height of a single piece in pixels
     */
    public function new(name:String, sx:Int, sy:Int, w:Int, h:Int) {
        this.name = name;
        sourceX = sx;
        sourceY = sy;
        width = w;
        height = h;
    }
    
    /**
     * Precompute UV-space coordinates
     * @param tWidth: Width of the sprite sheet
     * @param tHeight: Height of the sprite sheet
     */
    public function computeTrueCoords(tWidth:Int, tHeight:Int) {
        xMin = sourceX / tWidth;
        xMax = (sourceX + width) / tWidth;
        yMin = sourceY / tHeight;
        yMax = (sourceY + height) / tHeight;
    }
    
    public function setToTile(i:Image) {
        i.setTexCoordsTo(0, xMin, yMin);
        i.setTexCoordsTo(1, xMax, yMin);
        i.setTexCoordsTo(2, xMin, yMax);
        i.setTexCoordsTo(3, xMax, yMax);
    }
}
