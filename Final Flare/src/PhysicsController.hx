package;

import openfl.geom.Point;
import box2D.dynamics.contacts.B2Contact;
import box2D.dynamics.B2ContactListener;
import box2D.common.math.B2Vec2;
import box2D.dynamics.B2World;

class PhysicsController extends B2ContactListener
{
	private static var DT:Float = 1 / 60;
	public static var GRAVITY = new B2Vec2(0, 10);	
	
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

		if (entity1 == "player" && entity2 == "enemy") 
		{
			//PlayerController.handleCollision((Item*)model1, (Pedestrian*)model2);
		}
		else if (entity1 == "enemy" && entity2 == "player") 
		{
			//PlayerController.handleCollision((Item*)model1, (Pedestrian*)model2);
		}
		else if (entity1 == "enemy" && entity2 == "bullet") 
		{
			//TODO
		}
		
		else if (entity1 == "bullet" && entity2 == "enemy") 
		{
			//TODO
		}
	}
	
	
	public function update() 
	{
		world.step(DT, 8, 8);
		world.clearForces();
	}
}