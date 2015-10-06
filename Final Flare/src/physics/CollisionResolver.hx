package physics {
    /**
     * Collision Detection And Resolution Manager
     * @author Cristian Zaloj
     */
    public class CollisionResolver {
        public static var DISTANCE_TOLERANCE:Number = 1.05;
        public static var OFFSET_TOLERANCE:Number = 0.05;
        
        /**
         * If An Object Moves More Than This Amount In A Single Step, Shit Will Get Shat
         */
        public static var MAX_MOTION:Number = 0.2;
        public static var MAX_MOTION_ENT:Number = 0.205;
        /**
         * A Utility Used Upon Motion Values To Ensure Your Game Runs Without A Glitch
         * @param v Displacement Amount Desired In A Frame
         * @return A Displacement That Physics Engine Likes
         */
        public static function ClampedMotion(v:Number):Number {
            if (v < -MAX_MOTION) return -MAX_MOTION;
            if (v > MAX_MOTION) return MAX_MOTION;
            return v;
        }
        public static function ClampedMotionEntity(v:Number):Number {
            if (v < -MAX_MOTION_ENT) return -MAX_MOTION_ENT;
            if (v > MAX_MOTION_ENT) return MAX_MOTION_ENT;
            return v;
        }
        
        /**
         * Construct A Set Of Edges In The Frame Of Reference Of The Island
         * @param providers IPhysTile[y][x] Array
         * @return A Set Of Collision Edges
         */
        public static function ConstructEdges(providers:Array):Array {
            var edges:Array = [];
            var offset:Vector2 = new Vector2(0, 0);
            for (var y:int = 0; y < providers.length; y++) {
                for (var x:int = 0; x < providers[y].length; x++) {
                    if (providers[y][x] == null)
                        continue;
                    offset.Set(x, y);
                    
                    providers[y][x].ProvideEdgesSpecial(edges, offset);
                    
                    if (x == 0 || (providers[y][x - 1] == null)) {
                        providers[y][x].ProvideEdgesDirection(Cardinal.NX, edges, offset);
                    }
                    if (x == providers[y].length - 1 || (providers[y][x + 1] == null)) {
                        providers[y][x].ProvideEdgesDirection(Cardinal.PX, edges, offset);
                    }
                    if (y == 0 || (providers[y - 1][x] == null)) {
                        providers[y][x].ProvideEdgesDirection(Cardinal.NY, edges, offset);
                    }
                    if (y == providers.length - 1 || (providers[y + 1][x] == null)) {
                        providers[y][x].ProvideEdgesDirection(Cardinal.PY, edges, offset);
                    }
                }
            }
            return edges;
        }
        
        /**
         * Resolves Collision Between A Dynamic Body And A Set Of Islands
         * @param r Dynamic Body
         * @param iList List Of Islands
         * @param fCallback Callback Function For When Collision Inside Of An Island Wants To Be Resolved
         * (After Aggregation Step)
         * func(rect:PhysRectangle, accum:CollisionAccumulator, opt:PhysCallbackOptions):Boolean
         * @param fCollisionCallback Callback Function For When A Collision Occurs Inside Of An Island
         * (All Physics Objects Are In A Localized Coordinate Frame, Not A Global One)
         * func(rect:PhysRectangle, edgeOfCollision:PhysEdge, penetration:Number):void
         */
        public static function Resolve(r:PhysRectangle, iList:Array, fCallback:Function = null, fCollisionCallback:Function = null):void {
            var possibleCollisions:Array = [];
            var disp:Vector2 = new Vector2();
            var xBounds:Vector2i = new Vector2i();
            var yBounds:Vector2i = new Vector2i();
            var iBounds:PRect = new PRect()
            for each (var i:PhysIsland in iList) {
                // Test If Rectangles Overlap
                iBounds.center.Set(i.tilesWidth, i.tilesHeight).MulD(0.5).Add(i.globalAnchor.x, i.globalAnchor.y);
                iBounds.halfSize.Set(i.tilesWidth, i.tilesHeight).MulD(0.5).AddD(0.5);
                if (!PRect.intersects(iBounds, r.rect, disp)) continue;
                
                r.center.SubV(i.globalAnchor);
                xBounds.x = MathHelper.clampI(int(r.NX - 0.5), 0, i.tilesWidth - 1);
                xBounds.y = MathHelper.clampI(int(r.PX + 0.5), 0, i.tilesWidth - 1);
                yBounds.x = MathHelper.clampI(int(r.NY - 0.5), 0, i.tilesHeight - 1);
                yBounds.y = MathHelper.clampI(int(r.PY + 0.5), 0, i.tilesHeight - 1);
                r.center.AddV(i.globalAnchor);
                
                for (var iy:int = yBounds.x; iy <= yBounds.y; iy++) {
                    for (var ix:int = xBounds.x; ix <= xBounds.y; ix++) {
                        if (i.tileGrid[iy][ix] == null) continue;
                        
                        possibleCollisions.push(new PossibleTile(i, ix, iy));
                    }
                }
            }
            
            // Clip Edges
            cullEdges(possibleCollisions);
            
            // Sort Collisions By Distance
            r.rect.center.SubV(r.motion);
            possibleCollisions = possibleCollisions.sort(function (a:PossibleTile, b:PossibleTile):Number {
                var d1:Number = tileDistanceSq(a, r.rect, r.velocity);
                var d2:Number = tileDistanceSq(b, r.rect, r.velocity);
                return d1 - d2;
            });
            r.rect.center.AddV(r.motion);
            
            // Resolve Collisions
            var a:CollisionAccumulator = new CollisionAccumulator();
            for each (var pc:PossibleTile in possibleCollisions) {
                resolve(r, pc, a, fCollisionCallback);
            }
            
            // Use The Callback And Check If Resolution Should Continue
            var opt:PhysCallbackOptions = new PhysCallbackOptions();
            var doResolve:Boolean = fCallback == null ? true : fCallback.call(null, r, a, opt);
            
            // Resolve The Collision
            if (doResolve) {
                var dx = a.accumPX - a.accumNX;
                var dy = a.accumPY - a.accumNY;
                
                if (dx != 0 && opt.breakXVelocity)
                    r.velocity.x = 0;
                if (dy != 0 && opt.breakYVelocity)
                    r.velocity.y = 0;
                if (opt.resolveXDisplacement)
                    r.center.x += dx;
                if (opt.resolveYDisplacement)
                    r.center.y += dy;
            }
        }
        
        private static function tileDistanceSq(t:PossibleTile, r:PRect, v:Vector2):Number {
            var cx:Number = 0;
            if (r.center.x < t.rect.center.x) cx = r.center.x + r.halfSize.x;
            else cx = r.center.x - r.halfSize.x;
            var cy:Number = 0;
            if (r.center.y < t.rect.center.y) cy = r.center.y + r.halfSize.y;
            else cy = r.center.y - r.halfSize.y;
            
            cx -= t.rect.center.x;
            cy -= t.rect.center.y;
            return cx * cx + cy * cy;
        }
        public static function cullEdges(tiles:Array):void {
            for (var i1:int = 0; i1 < tiles.length - 1; i1++ ) {
                for (var i2:int = i1 + 1; i2 < tiles.length; i2++) {
                    checkEdges(tiles[i1], tiles[i2]);
                }
            }
        }
        private static function checkEdges(a:PossibleTile, b:PossibleTile):void {
            if (Math.abs(a.rect.center.x - b.rect.center.x) < DISTANCE_TOLERANCE) {
                if (Math.abs(a.rect.center.y - b.rect.center.y) < OFFSET_TOLERANCE) {
                    if (a.rect.center.x < b.rect.center.x) {
                        // Kill A.PX, B.NX
                        a.collidePX = false;
                        b.collideNX = false;
                    }
                    else {
                        // Kill A.NX, B.PX
                        a.collideNX = false;
                        b.collidePX = false;
                    }
                }
            }
            if (Math.abs(a.rect.center.y - b.rect.center.y) < DISTANCE_TOLERANCE) {
                if (Math.abs(a.rect.center.x - b.rect.center.x) < OFFSET_TOLERANCE) {
                    if (a.rect.center.y < b.rect.center.y) {
                        // Kill A.PY, B.NY
                        a.collidePY = false;
                        b.collideNY = false;
                    }
                    else {
                        // Kill A.NY, B.PY
                        a.collideNY = false;
                        b.collidePY = false;
                    }
                }
            }
        }
        
        private static function resolvePass(r:PhysRectangle, possibleCollisions:Array, fCallback:Function, fCollisionCallback:Function) {
            // Resolve Collisions
            var a:CollisionAccumulator = new CollisionAccumulator();
            for each (var pc:PossibleTile in possibleCollisions) {
                resolve(r, pc, a, fCollisionCallback);
            }
            
            // Use The Callback And Check If Resolution Should Continue
            var opt:PhysCallbackOptions = new PhysCallbackOptions();
            var doResolve:Boolean = fCallback == null ? true : fCallback.call(null, r, a, opt);
            
            // Resolve The Collision
            if (doResolve) {
                var dx = a.accumPX - a.accumNX;
                var dy = a.accumPY - a.accumNY;
                
                if (dx != 0 && opt.breakXVelocity)
                    r.velocity.x = 0;
                if (dy != 0 && opt.breakYVelocity)
                    r.velocity.y = 0;
                if (opt.resolveXDisplacement)
                    r.center.x += dx;
                if (opt.resolveYDisplacement)
                    r.center.y += dy;
            }
        }
        private static function resolve(r:PhysRectangle, t:PossibleTile, a:CollisionAccumulator, fCollisionCallback:Function):void {
            var disp:Vector2 = new Vector2(r.center.x, r.center.y).SubV(t.rect.center);
            var pen = new Vector2(disp.x, disp.y);
            if (pen.x < 0) pen.x = -pen.x;
            if (pen.y < 0) pen.y = -pen.y;
            pen.SubV(r.rect.halfSize).SubV(t.rect.halfSize);
            var hitX:Boolean = pen.x < pen.y;
            
            
            var dx = 0;
            var dy = 0;
            
            var rv:Vector2 = new Vector2(r.velocity.x, r.velocity.y).SubV(t.island.velocity);
            if (r.rect.NX <= t.rect.PX && r.rect.PX >= t.rect.NX && r.rect.NY <= t.rect.PY && r.rect.PY >= t.rect.NY) {
                if (t.collidePX && disp.x > 0 && rv.x < 0) {
                    if (r.rect.NX < t.rect.PX) {
                        dx = t.rect.PX - r.rect.NX;
                    }
                }
                else if (t.collideNX && disp.x < 0 && rv.x > 0) {
                    if (r.rect.PX > t.rect.NX) {
                        dx = t.rect.NX - r.rect.PX;
                    }
                }
                
                if (t.collidePY && disp.y > 0 && rv.y < 0) {
                    if (r.rect.NY < t.rect.PY) {
                        dy = t.rect.PY - r.rect.NY;
                    }
                }
                else if (t.collideNY && disp.y < 0 && rv.y > 0) {
                    if (r.rect.PY > t.rect.NY) {
                        dy = t.rect.NY - r.rect.PY;
                    }
                }
            }
            
            if (dx == 0 && dy == 0) return;
            dx *= 1.02;
            //dy *= 1.01;
            
            if (dy == 0 || (dx != 0 && Math.abs(dx) < Math.abs(dy))) {
                if (dx < 0) {
                    a.accumNX = Math.max(a.accumNX, -dx);
                    if (fCollisionCallback != null)
                        fCollisionCallback.call(null, new PhysEdge(Cardinal.NX, t.rect.NX, t.rect.center.y, 1.0), t.island.globalAnchor);
                }
                else {
                    a.accumPX = Math.max(a.accumPX, dx);
                    if (fCollisionCallback != null)
                        fCollisionCallback.call(null, new PhysEdge(Cardinal.PX, t.rect.PX, t.rect.center.y, 1.0), t.island.globalAnchor);
                }
            }
            else {
                if (dy < 0) {
                    a.accumNY = Math.max(a.accumNY, -dy);
                    if (fCollisionCallback != null)
                        fCollisionCallback.call(null, new PhysEdge(Cardinal.NY, t.rect.center.x, t.rect.NY, 1.0), t.island.globalAnchor);
                }
                else {
                    a.accumPY = Math.max(a.accumPY, dy);
                    if (fCollisionCallback != null)
                        fCollisionCallback.call(null, new PhysEdge(Cardinal.PY, t.rect.center.x, t.rect.PY, 1.0), t.island.globalAnchor);
                }
            }
        }
    }
}