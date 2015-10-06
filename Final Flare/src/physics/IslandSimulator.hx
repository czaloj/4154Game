package physics {
    import adobe.utils.CustomActions;
    import flash.accessibility.AccessibilityProperties;
    import flash.display.GraphicsPathWinding;
    import flash.geom.Point;
    import Vector2i;
    
    /**
     * Controller That Builds And Simulates A List Of Islands
     * @author Cristian Zaloj
     */
    public class IslandSimulator {
        /**
         * Construct Islands From A IPhysTile Level Input
         * @param tiles IPhysTile[y][x] Ordering Grid
         * @return A List Of Islands
         */
        public static function ConstructIslands(tiles:Array):Array {
            var queue = [];
            var ids:Array = BuildIDs(tiles, queue);
            MergeIDs(tiles, ids, queue);
            var islandPositions:Array = GetIslandPositions(ids);
            
            var islands = new Array(islandPositions.length);
            for (var i:int = 0; i < islandPositions.length; i++) {
                islands[i] = ConstructIsland(islandPositions[i], tiles);
            }
            
            return islands;
        }
        /**
         * Construct A Grid Of Unique IDs On Which Merging Will Take Place
         * @param tiles IPhysTile[y][x] Ordering Grid
         * @param queue Reference To A Queue Where The Locations Of Valid IDs Will Be Inserted
         * @return An ID Grid That Maps To The Tile Grid
         */
        private static function BuildIDs(tiles:Array, queue:Array):Array {
            var ids:Array = new Array(tiles.length);
            var uuid:int = 1;
            for (var y:int = 0; y < tiles.length; y++) {
                ids[y] = new Array(tiles[y].length);
                for (var x:int = 0; x < tiles[y].length; x++) {
                    var tile:IPhysTile = tiles[y][x];
                    if (tile == null) {
                        ids[y][x] = 0;
                    } else {
                        ids[y][x] = uuid;
                        queue.push(new Vector2i(x, y));
                        uuid++;
                    }
                }
            }
            return ids;
        }
        /**
         * Performs A Merging Algorithm On The ID Grid That Binds As Many Tilss As Possible
         * @param tiles IPhysTile[y][x] Ordering Grid
         * @param ids ID Grid That Maps To Tiles
         * @param queue A Queue Of Locations
         */
        private static function MergeIDs(tiles:Array, ids:Array, queue:Array) {
            var h:int = tiles.length;
            var otherPos:Vector2i = new Vector2i(0, 0);
            while (queue.length > 0) {
                var pos:Vector2i = queue.shift();
                var w:int = tiles[pos.y].length;
                
                // Merge In Four Directions
                if (pos.x > 0)
                    MergeTiles(tiles, ids, pos, (otherPos.SetV(pos)).Sub(1, 0), Cardinal.NX);
                if (pos.x < w - 1)
                    MergeTiles(tiles, ids, pos, (otherPos.SetV(pos)).Add(1, 0), Cardinal.PX);
                if (pos.y > 0)
                    MergeTiles(tiles, ids, pos, (otherPos.SetV(pos)).Sub(0, 1), Cardinal.NY);
                if (pos.y < h - 1)
                    MergeTiles(tiles, ids, pos, (otherPos.SetV(pos)).Add(0, 1), Cardinal.PY);
            }
        }
        /**
         * Attempt To Merge Islands That Two Tiles Occupy
         * @param tiles IPhysTile[y][x] Ordering Grid
         * @param ids ID Grid That Maps To Tiles
         * @param p1 Position Of The First Tile
         * @param p2 Position Of The Second Tile
         * @param dir12 Direction Of Tile 2 From Tile 1 On Which Swapping Occurs
         */
        private static function MergeTiles(tiles:Array, ids:Array, p1:Vector2i, p2:Vector2i, dir12:int) {
            var t1:IPhysTile = tiles[p1.y][p1.x];
            var id1:int = ids[p1.y][p1.x];
            var t2:IPhysTile = tiles[p2.y][p2.x];
            var id2:int = ids[p2.y][p2.x];
            
            // Check For Abscence And Merge History
            if (t1 == null || t2 == null)
                return;
            if (id1 == id2)
                return;
            
            // Check If They Can Bind In Both Directions
            if (t1.CanBind(dir12,t2) && t2.CanBind(dir12 ^ 1,t1)) {
                // Set To The Minimum ID
                if (id1 < id2)
                    SwapIDs(ids, p2.x, p2.y, id2, id1);
                else
                    SwapIDs(ids, p1.x, p1.y, id1, id2);
            }
            return;
        }
        /**
         * Recursively Overwrite An Island With Another's ID
         * @param ids Island ID[y][x] Grid
         * @param x X-Pos Where Overwriting Will Be Attempted
         * @param y Y-Pos Where Overwriting Will Be Attempted
         * @param idRef Which Island ID To Overwrite
         * @param idSwap Dominant ID
         */
        private static function SwapIDs(ids:Array, x:int, y:int, idRef:int, idSwap:int) {
            if (ids[y][x] == idRef) {
                ids[y][x] = idSwap;
                
                var h:int = ids.length;
                var w:int = ids[y].length;
                
                if (x > 0)
                    SwapIDs(ids, x - 1, y, idRef, idSwap);
                if (x < w - 1)
                    SwapIDs(ids, x + 1, y, idRef, idSwap);
                if (y > 0)
                    SwapIDs(ids, x, y - 1, idRef, idSwap);
                if (y < h - 1)
                    SwapIDs(ids, x, y + 1, idRef, idSwap);
            }
        }
        /**
         * Calculate The (NX,NY) Corners Of All The Merged Islands In A Grid
         * @param ids Island ID[y][x] Grid
         * @return A List Of (x,y) Integer Locations
         */
        private static function GetIslandPositions(ids:Array):Array {
            var map:Object = new Object();
            var islandPositions = [];
            
            for (var y:int = 0; y < ids.length; y++) {
                for (var x:int = 0; x < ids[y].length; x++) {
                    var id:int = ids[y][x];
                    
                    // Skip If Nothing
                    if (id == 0)
                        continue;
                    
                    var idS:String = id.toString();
                    if (!map.hasOwnProperty(idS)) {
                        // Create A New Position Set
                        var newIsland:Array = [];
                        map[idS] = newIsland;
                        islandPositions.push(newIsland);
                    }
                    
                    // Add Position To Island
                    map[idS].push(new Vector2i(x, y));
                }
            }
            
            return islandPositions;
        }
        /**
         * Create An Island From A Specific Location In The Tile Grid
         * @param pos (NX, NY) Corner Of An Island
         * @param tiles IPhysTile[y][x] Ordering Grid
         * @return A Fully Constructed Island
         */
        private static function ConstructIsland(pos:Array, tiles:Array):PhysIsland {
            var xBounds:Vector2i = new Vector2i(int.MAX_VALUE, int.MIN_VALUE);
            var yBounds:Vector2i = new Vector2i(int.MAX_VALUE, int.MIN_VALUE);
            
            for each (var p:Vector2i in pos) {
                if (p.x < xBounds.x)
                    xBounds.x = p.x;
                if (p.x > xBounds.y)
                    xBounds.y = p.x;
                if (p.y < yBounds.x)
                    yBounds.x = p.y;
                if (p.y > yBounds.y)
                    yBounds.y = p.y;
            }
            
            // Create Island At Its Starting Min Location
            var island:PhysIsland = new PhysIsland(xBounds.y - xBounds.x + 1, yBounds.y - yBounds.x + 1);
            island.tileOriginalLocation.Set(xBounds.x, yBounds.x);
            island.x = xBounds.x;
            island.y = yBounds.x;
            
            // Add All The Tiles
            for each (var p:Vector2i in pos) {
                var tile:IPhysTile = tiles[p.y][p.x];
                p.Sub(xBounds.x, yBounds.x);
                island.AddTile(p.x, p.y, tile);
            }
            
            // Construct Edges
            return island;
        }
        
        
        /**
         * Construct The Physics Structures That Handle Gravity Collisions
         * @param islands The List Of Islands
         * @return A Jagged List Of Lists Of Collision Collumns
         */
        public static function ConstructCollisionColumns(islands:Array):Array {
            // Create A List Of All The Columns
            var minX:int = int.MAX_VALUE;
            var maxX:int = int.MIN_VALUE;
            for each(var island:PhysIsland in islands) {
                var iMinX:int = int(island.globalAnchor.x + 0.5);
                var iMaxX:int = iMinX + island.tilesWidth - 1;
                if (iMinX < minX) minX = iMinX;
                if (iMaxX > maxX) maxX = iMaxX;
            }
            var totalWidth:int = maxX - minX + 1
            var hashSet = new Array(totalWidth);
            for (var i:int = 0; i < totalWidth; i++) {
                hashSet[i] = [];
            }
            
            // Hash All Columns
            for each(var island:PhysIsland in islands) {
                var igX:int = int(island.globalAnchor.x + 0.5);
                igX -= minX;
                var columns = BuildIslandCollisionColumns(island);
                for each(var cc:CollisionColumn in columns) {
                    var cx:int = int(cc.pyEdge.center.x);
                    hashSet[igX + cx].push(cc);
                }
            }
            
            return hashSet;
        }
        /**
         * Build All The Collision Columns That Exist Within An Island
         * @param island The Island
         * @return All The Collision Columns Of The Island
         */
        private static function BuildIslandCollisionColumns(island:PhysIsland):Array { 
            var cols:Array = [];
            for (var x:int = 0; x < island.tilesWidth; x++) {
                var y:int = 0;
                while (y < island.tilesHeight) {
                    while (y < island.tilesHeight && island.tileGrid[y][x] == null) y++;
                    if (y == island.tilesHeight) continue;
                    var sy:int = y;
                    while (y < island.tilesHeight && island.tileGrid[y][x] != null) y++;

                    cols.push(CreateColumn(island, x, sy, y - sy));
                }
            }
            
            return cols;
        }
        /**
         * Build A Vertical Column Segment In An Island
         * @param island The Column's Island
         * @param x Island's Relative X Position For Column
         * @param sy Y Index Of Starting Tile
         * @param c Number Of Tiles To Use
         * @return A Collision Column
         */
        private static function CreateColumn(island:PhysIsland, x:int, sy:int, c:int):CollisionColumn {
            var col:CollisionColumn = new CollisionColumn(island);
            col.nyEdge = new PhysEdge(Cardinal.NY, x + 0.5, sy, 1.0);
            col.pyEdge = new PhysEdge(Cardinal.PY, x + 0.5, sy + c, 1.0);
            return col;
        }
        
        /**
         * Apply Gravity To Islands And Resolve Collisions Between Themselves
         * @param islands A List Of Islands
         * @param columns A List Of Columns
         * @param gravAcceleration Acceleration Vector In Physics Engine Units
         * @param dt Time Step Of The Simulation
         */
        public static function Simulate(islands:Array, columns:Array, gravAcceleration:Vector2, dt:Number):void {
            for each(var island:PhysIsland in islands) {
                if (!island.isGrounded) {
                    island.velocity.Add(gravAcceleration.x * dt, gravAcceleration.y * dt);
                    island.motion.SetV(island.velocity).MulD(dt);
                    island.motion.x = CollisionResolver.ClampedMotion(island.motion.x);
                    island.motion.y = CollisionResolver.ClampedMotion(island.motion.y);
                    island.globalAnchor.AddV(island.motion);
                    island.resetBoundingRect();
                    island.columnAccumulator.Set(0, 0);
                }
            }
            
            // Accumulate Collision Between Islands
            for each(var columnList:Array in columns) {
                for each(var c1:CollisionColumn in columnList) {
                    for each(var c2:CollisionColumn in columnList) {
                        CollideColumns(c1, c2);
                    }
                }
            }
            
            // Resolve Collisions Between Islands
            for each(var island:PhysIsland in islands) {
                var dy:Number = island.columnAccumulator.y - island.columnAccumulator.x;
                if (dy != 0.0) {
                    island.velocity.y = 0.0;
                    island.motion.y += dy;
                    island.globalAnchor.y += dy;
                    island.resetBoundingRect();
                }
                island.motion.MulD(1.1);
            }
        }
        /**
         * Detect And Accumulate Collision Resolution Data Between Two Columns
         * @param c1 Column 1
         * @param c2 Column 2
         */
        private static function CollideColumns(c1:CollisionColumn, c2:CollisionColumn) {
            if ((c1 == c2) || (c1.island == c2.island) || (c1.island.isGrounded && c2.island.isGrounded)) return;
            
            var c1y:Number = (c1.pyEdge.center.y + c1.nyEdge.center.y) * 0.5 + c1.island.globalAnchor.y;
            var c2y:Number = (c2.pyEdge.center.y + c2.nyEdge.center.y) * 0.5 + c2.island.globalAnchor.y;
            
            var off:Number;
            var top:Number;
            var bot:Number;
            if (c1y > c2y) {
                top = c1.nyEdge.center.y + c1.island.globalAnchor.y;
                bot = c2.pyEdge.center.y + c2.island.globalAnchor.y;
                off = top - bot;
                if (off < 0) DisplaceIsland(c1, c2, -off);
            }
            else {
                top = c2.nyEdge.center.y + c2.island.globalAnchor.y;
                bot = c1.pyEdge.center.y + c1.island.globalAnchor.y;
                off = top - bot;
                if (off < 0) DisplaceIsland(c2, c1, -off);
            }
            
        }
        /**
         * Accumulate Island Displacement Between Two Columns
         * @param cPY The Column Located Towards The Positive Y
         * @param cNY The Column Located Towards The Negative Y
         * @param off The Penetration Distance Of The Columns
         */
        private static function DisplaceIsland(cPY:CollisionColumn, cNY:CollisionColumn, off:Number) {
            if (!cNY.island.isGrounded) {
                // Displace Lower One
                cNY.island.columnAccumulator.x = Math.max(cNY.island.columnAccumulator.x, off);
            }
            else if(!cPY.island.isGrounded) {
                // Displace Higher One
                cPY.island.columnAccumulator.y = Math.max(cPY.island.columnAccumulator.y, off);
            }
            else {
                // Displace Both
                cPY.island.columnAccumulator.y = Math.max(cPY.island.columnAccumulator.y, off / 2);
                cNY.island.columnAccumulator.x = Math.max(cNY.island.columnAccumulator.x, off / 2);
            }
        }
        
        public static function DestroyTile(island:PhysIsland, x:int, y:int):Array {
            // Perform Checks To See If Anything Is Changed
            if (x < 0 || x >= island.tilesWidth) return [island];
            if (y < 0 || y >= island.tilesHeight) return [island];
            if (island.tileGrid[y][x] == null) return [island];
            
            // Check If This Will Destroy The Entire Island
            if (island.tilesWidth == 1 && island.tilesHeight == 1) return null;
            
            // Destroy The Tile
            island.tileGrid[y][x] = null;
            
            // Rebuild New Islands
            var newIslands:Array = IslandSimulator.ConstructIslands(island.tileGrid);
            if (newIslands == null || newIslands.length < 1) return null;
            
            // Add Back The Original Island Offsets To The New Islands
            for each(var newIsland:PhysIsland in newIslands) {
                newIsland.globalAnchor.AddV(island.globalAnchor);
                newIsland.tileOriginalLocation.AddV(island.tileOriginalLocation);
            }
            
            return newIslands;
        }
    }
}