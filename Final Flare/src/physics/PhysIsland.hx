package physics {
    
    /**
     * ...
     * @author Cristian Zaloj
     */
    public class PhysIsland {
        // The Original Location Of The Island In The Tile Grid
        public var tileOriginalLocation:Vector2i = new Vector2i();

        // The Location Of The Island In World For Relative Calculations
        public var globalAnchor:Vector2 = new Vector2();
        public var velocity:Vector2 = new Vector2();
        public var motion:Vector2 = new Vector2();
        
        // Width And Height Of Island In Tiles
        public var tilesWidth:int;
        public var tilesHeight:int;
        
        // Tiles Of The Island
        public var tileGrid:Array;
        
        // Bounding Rectangle Of The Island
        public var boundingRect:PRect = new PRect();

        // Used For Island-Island Collision
        public var columnAccumulator:Vector2 = new Vector2();
        
        /**
         * Should This Island Be Hovering
         */
        public var isGrounded:Boolean = false;
        
        public function PhysIsland(w:int, h:int) {
            tilesWidth = w;
            tilesHeight = h;
            boundingRect.halfSize.Set(w, h).MulD(0.5);
            
            tileGrid = new Array(tilesHeight);
            for (var i:int; i < tileGrid.length; i++) {
                tileGrid[i] = new Array(tilesWidth);
            }
        }
        
        public function set x(v:Number):void {
            globalAnchor.x = v;
            boundingRect.center.x = globalAnchor.x + boundingRect.halfSize.x;
        }
        public function set y(v:Number):void {
            globalAnchor.y = v;
            boundingRect.center.y = globalAnchor.y + boundingRect.halfSize.y;
        }
        public function set position(v:Vector2):void {
            x = v.x;
            y = v.y;
        }
        
        public function AddTile(x:int, y:int, tile:IPhysTile):void {
            if (tile == null)
                return;
            
            tileGrid[y][x] = tile;
            
            // Add Grounding To The Island
            isGrounded = isGrounded || tile.IsGrounded;
        }
        
        public function getBoundingRect():PRect {
            var r:PRect = new PRect();
            r.halfSize.Set(tilesWidth, tilesHeight).MulD(0.5);
            r.center.SetV(globalAnchor).AddV(r.halfSize);
            return r;
        }
        
        public function resetBoundingRect():void {
            boundingRect.center.SetV(globalAnchor).AddV(boundingRect.halfSize);
        }
    }
}