package {
    /**
     * 
     * @author Cristian Zaloj
     */
    public class Cardinal {
        /**
         * Negative X Direction = 0
         */
        public static var NX:int = 0;
        /**
         * Positive X Direction = 1
         */
        public static var PX:int = 1;
        /**
         * Negative Y Direction = 2
         */
        public static var NY:int = 2;
        /**
         * Positive Y Direction = 3
         */
        public static var PY:int = 3;
        
        public static var DIRECTIONS:Array = [NX, PX, NY, PY];
        public static var DIRECTION_VECTORS:Array = [
            new Vector2i(-1, 0), new Vector2i(1, 0), new Vector2i(0, -1), new Vector2i(0, 1)
        ];
        
        public static function isValidDir(dir:int):Boolean {
            return DIRECTIONS.indexOf(dir) != -1;
        }
        
        public static function getOpposite(dir:int):int {
            switch (dir) {
                case NX: return PX;
                case PX: return NX;
                case NY: return PY;
                case PY: return NY;
            }
            throw new Error("not a real direction");
        }
        
        public static function getVector2i(dir:int):Vector2i {
            var vector:Vector2i = DIRECTION_VECTORS[dir];
            if (vector == undefined) {
                throw new Error("not a real direction");
            }
            return vector.copy();
        }
        
        public static function getDir(vector:Vector2i):int {
            for (var i:int = 0; i < DIRECTION_VECTORS.length; i++) {
                if (vector.x == DIRECTION_VECTORS[i].x && vector.y == DIRECTION_VECTORS[i].y) {
                    return i;
                }
            }
            throw new Error("not a real direction vector");
        }
        
    }

}