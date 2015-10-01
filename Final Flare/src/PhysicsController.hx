package;

import openfl.geom.Point;
import box2D.common.math.B2Vec2;
import box2D.dynamics.B2World;

class PhysicsController
{
	private static var DT:Float = 1 / 60;
	public static var GRAVITY = new B2Vec2(0, 10);	
	
	public var world:B2World;
	

	public function new() 
	{
		init();
	}
	
	private function init():Void 
	{
		world = new B2World(GRAVITY, true);
		
	}
	
	public function update() 
	{
		world.step(DT, 8, 8);
		world.clearForces();
	}
}