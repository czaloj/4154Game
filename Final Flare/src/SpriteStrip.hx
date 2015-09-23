package;

import starling.display.Image;

class SpriteStrip {
    // Name of the strip
    public var name:String;

    // Strip pixel information 
    private var sourceX:Int;
    private var sourceY:Int;
    public var width:Int;
    public var height:Int;
    
    // Strip frame organization
    private var rows:Int;
    private var columns:Int;
    public var totalFrames:Int;
    
    // UV-space information
    private var xMin:Float;
    private var xDelta:Float;
    private var yMin:Float;
    private var yDelta:Float;
    
    /**
     * @param name: Name of the strip within the sprite sheet
     * @param sx: Pixel X starting location
     * @param sy: Pixel Y starting location
     * @param w: Width of a single piece in pixels
     * @param h: Height of a single piece in pixels
     * @param r: Rows of sprite pieces
     * @param c: Columns of sprite pieces
     * @param frames: Count of frames of animation
     */
    public function new(name:String, sx:Int, sy:Int, w:Int, h:Int, r:Int, c:Int, frames:Int) {
        this.name = name;
        sourceX = sx;
        sourceY = sy;
        width = w;
        height = h;
        rows = r;
        columns = c;
        totalFrames = frames;
    }
    
    /**
     * Precompute UV-space coordinates
     * @param tWidth: Width of the sprite sheet
     * @param tHeight: Height of the sprite sheet
     */
    public function computeTrueCoords(tWidth:Int, tHeight:Int) {
        xMin = sourceX / tWidth;
        xDelta = width / tWidth;
        yMin = sourceY / tHeight;
        yDelta = height / tHeight;
    }
    
    public function setToFrame(i:Image, frame:Int) {
        var x:Int = Std.int(frame % columns);
        var x1:Float = xMin + xDelta * x;
        var x2:Float = x1 + xDelta;
        var y:Int = Std.int(frame / columns);
        var y1:Float = yMin + yDelta * y;
        var y2:Float = y1 + yDelta;

        i.setTexCoordsTo(0, x1, y1);
        i.setTexCoordsTo(1, x2, y1);
        i.setTexCoordsTo(2, x1, y2);
        i.setTexCoordsTo(3, x2, y2);
    }
}