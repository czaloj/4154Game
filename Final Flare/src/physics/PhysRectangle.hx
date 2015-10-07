package physics {
    import flash.geom.Rectangle;
    import pyrokid.Constants;
    /**
     * ...
     * @author Cristian Zaloj
     */
    public class PhysRectangle {
        public var rect:PRect = new PRect();
        
        public function get center():Vector2 {
            return rect.center;
        }
        public function get halfSize():Vector2 {
            return rect.halfSize;
        }
        
        public var velocity:Vector2 = new Vector2();
        public var motion:Vector2 = new Vector2();
        
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
    
        public function Update():void {
            motion.SetV(velocity).MulD(Constants.DT);
            motion.x = CollisionResolver.ClampedMotionEntity(motion.x);
            motion.y = CollisionResolver.ClampedMotionEntity(motion.y);
            center.AddV(motion);
        }
    }

}