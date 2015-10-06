package physics {
	/**
     * ...
     * @author Cristian Zaloj
     */
    public class CollisionColumn {
        public var island:PhysIsland;
        public var pyEdge:PhysEdge = null;
        public var nyEdge:PhysEdge = null;
        
        public function CollisionColumn(i:PhysIsland) { 
            island = i;
        }
    }
}