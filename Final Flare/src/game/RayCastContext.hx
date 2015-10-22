package game;

import box2D.dynamics.B2Fixture;

class RayCastContext {
    // For single-target cast
    public var closestFixture:Pair<B2Fixture, Float> = null;

    public var wallFraction:Float = 1.0;
    
    // For grabbing closest N results
    public var closestNFixtures:Array<Pair<B2Fixture, Float>> = [];
    public var maxHits:Int = 0;
    public var farthestHitFraction:Float = 1.0;
    
    // For grabbing all pierced fixtures
    public var piercedFixtures:Array<Pair<B2Fixture, Float>> = [];
    
    public var discardCategories:Int = 0;
    public var hitCategories:Int = 0;
    
    public function new() {
        // Empty
    }
}
