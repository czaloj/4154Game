package physics {
    /**
     * Accumulates Displacements In Each Cardinal Direction
     * @author Cristian Zaloj
     */
    public class CollisionAccumulator {
        /**
         * Max Penetration In Negative X Direction
         */
        public var accumPX:Number = 0.0;
        /**
         * Max Penetration In Positive X Direction
         */
        public var accumNX:Number = 0.0;
        /**
         * Max Penetration In Negative Y Direction
         */
        public var accumPY:Number = 0.0;
        /**
         * Max Penetration In Positive Y Direction
         */
        public var accumNY:Number = 0.0;
    }

}