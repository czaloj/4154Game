package physics {
    /**
     * ...
     * @author Cristian Zaloj
     */
    public class PhysEdge {
        /**
         * Midpoint Of This Edge
         */
        public var center:Vector2;
        /**
         * Half Of The Length Of This Edge
         */
        public var halfSize:Number;
        
        /**
         * Cardinal Direction That This Edge Faces
         */
        public var direction:int;

        /**
         * Constructor
         * @param d Cardinal Facing Direction
         * @param x Midpoint X Coordinate
         * @param y Midpoint Y Coordinate
         * @param s Length Of This Edge
         */
        public function PhysEdge(d:int, x:Number, y:Number, s:Number) {
            direction = d;
            center = new Vector2(x, y);
            halfSize = s / 2.0;
        }
    
        public function Clone(off:Vector2):PhysEdge {
            return new PhysEdge(direction, center.x + off.x, center.y + off.y, halfSize * 2);
        }
    }

}