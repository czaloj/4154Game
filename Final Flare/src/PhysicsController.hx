package;

import openfl.geom.Point;
import box2D.dynamics.contacts.B2Contact;
import box2D.dynamics.B2ContactListener;
import box2D.common.math.B2Vec2;
import box2D.dynamics.B2World;

class PhysicsController extends B2ContactListener
{
	private static var DT:Float = 1 / 60;
	public static var GRAVITY = new B2Vec2(0,0);
	
	public var world:B2World;
	

	public function new() 
	{
		super();
		init();
	}
	
	private function init():Void 
	{
		world = new B2World(GRAVITY, true);
		world.setContactListener(this);		
	}
	
	public function BeginContact(contact:B2Contact): Void 
	{
		//check what was in collision
		var entity1 = contact.getFixtureA().getBody().getUserData(); 
		var entity2 = contact.getFixtureB().getBody().getUserData();
		trace(entity1);
		trace(entity2);

		if (entity1 == "player" && entity2 == "platform") 
		{
			//GameplayScreen.handlePlayerCollision();
		}
		else if (entity1 == "platform" && entity2 == "player") 
		{
			//GameplayScreen.handlePlayerCollision();
		}
	}
	
	
	public function update() 
	{
		world.step(DT, 8, 5);
		world.clearForces();
	}
}