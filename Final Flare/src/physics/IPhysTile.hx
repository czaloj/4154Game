package physics {
    
    /**
     * ...
     * @author Cristian Zaloj
     */
    public interface IPhysTile {
        /**
         * Append Any Important Edges That Can Always Have Collisions
         * @param e Reference To Edge List
         * @param offset Amount To Diplace Collision Geometry Assuming Tile Is Unit Square [0,1]x[0,1]
         */
        function ProvideEdgesSpecial(e:Array, offset:Vector2):void;
        /**
         * Append Edges Facing In The Specified Cardinal Direction
         * @param side Cardinal Facing Direction Of Edges
         * @param e Reference To Edge List
         * @param offset Amount To Diplace Collision Geometry Assuming Tile Is Unit Square [0,1]x[0,1]
         */
        function ProvideEdgesDirection(side:int, e:Array, offset:Vector2):void;
        
        /**
         * True If This Provides A Grounding
         */
        function get IsGrounded():Boolean;
        
        /**
         * Used For Initial Binding Phase When A Level Loads
         * @param side Cardinal Direction
         * @return True If Binding In That Direction Is Possible
         */
        function CanBind(side:int, neighbor:IPhysTile):Boolean;
    }
    
}