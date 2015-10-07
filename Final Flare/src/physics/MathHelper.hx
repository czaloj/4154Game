package physics {
    /**
     * ...
     * @author Cristian Zaloj
     */
    public class MathHelper {
        public static function clampI(v:int, min:int, max:int):int {
            if (v < min) return min;
            if (v > max) return max;
            return v;
        }
        public static function clampF(v:Number, min:Number, max:Number):Number {
            if (v < min) return min;
            if (v > max) return max;
            return v;
        }
    }

}