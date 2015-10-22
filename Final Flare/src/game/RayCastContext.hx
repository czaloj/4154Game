package game;

import box2D.dynamics.B2Fixture;
import box2D.common.math.B2Vec2;

// Collided fixture, ray ratio, collision point, collision normal 
typedef RayCastInstance = Tuple4<B2Fixture, Float, B2Vec2, B2Vec2>;

class RayCastContext {
    public var hitWall:RayCastInstance = null;
    
    // For single-target cast
    public var closestFixture:RayCastInstance = null;

    
    public var wallFraction:Float = 1.0;
    
    // For grabbing closest N results
    public var closestNFixtures:Array<RayCastInstance> = [];
    public var maxHits:Int = 0;
    public var farthestHitFraction:Float = 1.0;
    
    // For grabbing all pierced fixtures
    public var piercedFixtures:Array<RayCastInstance> = [];
    
    public var discardCategories:Int = 0;
    public var hitCategories:Int = 0;
    
    public function new() {
        // Empty
    }
}
