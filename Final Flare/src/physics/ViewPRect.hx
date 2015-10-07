package physics {
    import flash.display.Sprite;
    import pyrokid.Constants;
    import pyrokid.entities.FreeEntity;
    import Utils;
    /**
     * ...
     * @author Cristian Zaloj
     */
    public class ViewPRect {
        public var sprite:FreeEntity;
        public var phys:PhysRectangle;
        public var isFreeEntity:Boolean;
        //public var callback:Function = null;
        
        public function ViewPRect(s:FreeEntity, p:PhysRectangle) {
            sprite = s;
            phys = p;
            isFreeEntity = sprite is FreeEntity;
        }
        
        /**
         * Resolve Physics And Update Sprite
         * @param islands Array Of PhysIslands
         */
        public function onUpdate(islands:Array, accumCallback:Function = null, collisionCallback:Function = null):void {
            phys.center.Set(sprite.x, sprite.y).DivD(Constants.CELL).AddV(phys.halfSize);
            phys.velocity.x = sprite.velocity.x / Constants.CELL;
            phys.velocity.y = sprite.velocity.y / Constants.CELL;
            
            sprite.isGrounded = false;
            sprite.touchLeft = false;
            sprite.touchRight = false;
            sprite.touchTop = false;
            
            phys.Update();
            CollisionResolver.Resolve(phys, islands, accumCallback, collisionCallback);
            
            sprite.x = (phys.center.x - phys.halfSize.x) * Constants.CELL;
            sprite.y = (phys.center.y - phys.halfSize.y) * Constants.CELL;
            sprite.velocity.x = phys.velocity.x * Constants.CELL;
            sprite.velocity.y = phys.velocity.y * Constants.CELL;
        }
    }

}