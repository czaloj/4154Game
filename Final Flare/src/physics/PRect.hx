package physics {
	/**
     * ...
     * @author Cristian Zaloj
     */
    public final class PRect {
        /**
         * Center Point Of The Rectangle
         */
        public var center:Vector2 = new Vector2(0, 0)
        /**
         * Half The Size Of The Full Rectangle
         */
        public var halfSize:Vector2 = new Vector2(1, 1)
        
        public function get NX():Number {
            return center.x - halfSize.x;
        }
        public function get PX():Number {
            return center.x + halfSize.x;
        }
        public function get NY():Number {
            return center.y - halfSize.y;
        }
        public function get PY():Number {
            return center.y + halfSize.y;
        }
        
        public function set NX(v:Number):void {
            center.x = v + halfSize.x;
        }
        public function set PX(v:Number):void {
            center.x = v - halfSize.x;
        }
        public function set NY(v:Number):void {
            center.y = v + halfSize.y;
        }
        public function set PY(v:Number):void {
            center.y = v - halfSize.y;
        }
        
        /**
         * Rectangle-To-Rectangle Intersection
         * @param r1 Rectangle 1
         * @param r2 Rectangle 2
         * @param outDisp Non-null Vector2 That Hold (r2.center - r1.center)
         * @return True If An Intersection Occurred
         */
        public static function intersects(r1:PRect, r2:PRect, outDisp:Vector2):Boolean {
            // Go To Local Frame Of r1
            outDisp.SetV(r2.center).SubV(r1.center);
            
            // Combine Sizes
            var sx:Number = r1.halfSize.x + r2.halfSize.x;            
            var sy:Number = r1.halfSize.y + r2.halfSize.y;
            
            // Test Point In Combined Sizes
            return outDisp.x >= -sx && outDisp.x <= sx && outDisp.y >= -sy && outDisp.y <= sy;
            
        }
    }

}