package;

import starling.display.Image;

class SpriteStrip {
    public var name:String;

    var sourceX:Int;
    var sourceY:Int;
    public var width:Int;
    public var height:Int;
    var rows:Int;
    var columns:Int;
    public var totalFrames:Int;
    var xMin:Float;
    var xDelta:Float;
    var yMin:Float;
    var yDelta:Float;
    
    /**
     * @param sx: Pixel X starting location
     * @param sy: Pixel Y starting location
     * @param w: Width of a single piece in pixels
     * @param h: Height of a single piece in pixels
     * @param r: Rows of sprite pieces
     * @param c: Columns of sprite pieces
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