package physics {
    /**
     * ...
     * @author Cristian Zaloj
     */
    internal class PossibleTile {
        public var rect:PRect = new PRect();
        public var island:PhysIsland;
        public var tx:int;
        public var ty:int;
        
        public var collideNX:Boolean = true;
        public var collidePX:Boolean = true;
        public var collideNY:Boolean = true;
        public var collidePY:Boolean = true;
        
        public function PossibleTile(i:PhysIsland, x:int, y:int) {
            island = i;
            tx = x;
            ty = y;
            
            rect.center.SetV(island.globalAnchor).Add(tx + 0.5, ty + 0.5);
            rect.halfSize.Set(0.5, 0.5);
            
            if ((ty > 0) && (i.tileGrid[ty - 1][tx] != null))
                collideNY = false;
            if ((ty < i.tilesHeight - 1) && (i.tileGrid[ty + 1][tx] != null))
                collidePY = false;
            if ((tx > 0) && (i.tileGrid[ty][tx - 1] != null))
                collideNX = false;
            if ((tx < i.tilesWidth - 1) && (i.tileGrid[ty][tx + 1] != null))
                collidePX = false;
        }
    }

}