package physics {
    import flash.display.Sprite;
    import pyrokid.Constants;
    import pyrokid.Island;
    import Utils;
    /**
     * ...
     * @author Cristian Zaloj
     */
    public class ViewPIsland {
        public var sprite:Island;
        public var phys:PhysIsland;
        
        public function ViewPIsland(s:Island, p:PhysIsland) {
            sprite = s;
            phys = p;
        }
        
        /**
         * All Islands Need To Simulated At Once
         * @param islands Array Of PhysIslands
         * @param grav Gravity Acceleration
         * @param dt Frame Delta-Time
         */
        public static function updatePhysics(islands:Array, columns:Array, grav:Vector2) {
            IslandSimulator.Simulate(islands, columns, grav, Constants.DT);
        }
        
        /**
         * Update Sprite Position To Match Physics
         */
        public function onUpdate():void {
            sprite.velocity = phys.velocity.copy().MulD(Constants.CELL);
            sprite.globalAnchor = phys.globalAnchor.copy();
        }
    }
}