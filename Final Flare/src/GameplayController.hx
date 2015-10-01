package;

import openfl.geom.Point;
import box2D.dynamics.B2Body;
import box2D.dynamics.B2BodyDef;
import box2D.dynamics.B2Fixture;
import box2D.dynamics.B2FixtureDef;
import box2D.collision.shapes.B2PolygonShape;
import box2D.common.math.B2Vec2;

import box2D.dynamics.B2World;

class GameplayController {
	
	private static var DT:Float = 1 / 60;
	public static var GRAVITY = new B2Vec2(0, -9.8);	
	private static var PHYSICS_SCALE:Float = 1 / 30;
	
    private var playerController:PlayerController;
	private var physicsController:PhysicsController;
	
	

    public function new(state:GameState) {
        init(state);
    }
	
	public function init(state:GameState):Void 
	{
		state.player = new ObjectModel();
		physicsController = new PhysicsController();	
		playerController = new PlayerController(state.player, physicsController.world);
		
		//Makes bottom platform. I'm unsure of the actual sizes
		var bottomPlatform = new ObjectModel();
		bottomPlatform.id = "platform";
        bottomPlatform.position.set(-400, -225);
        bottomPlatform.grounded = false;
        bottomPlatform.rotation = 0;
        bottomPlatform.velocity.set(0,0);
        bottomPlatform.left = false;
        bottomPlatform.right = false;
		bottomPlatform.height = 800;
		bottomPlatform.width - 32;
		
		bottomPlatform.bodyDef = new B2BodyDef();
		bottomPlatform.bodyDef.position.set(bottomPlatform.position.x * PHYSICS_SCALE, bottomPlatform.position.y * PHYSICS_SCALE);
		bottomPlatform.bodyDef.type = B2Body.b2_staticBody;
	 
		var polygon = new B2PolygonShape ();
		polygon.setAsBox ((bottomPlatform.width / 2) * PHYSICS_SCALE, (bottomPlatform.height / 2) * PHYSICS_SCALE);
		//trace(polygon.getVertices());
	 
		bottomPlatform.fixtureDef = new B2FixtureDef();
		bottomPlatform.fixtureDef.shape = polygon;
		bottomPlatform.body = physicsController.world.createBody(bottomPlatform.bodyDef);
		bottomPlatform.body.createFixture(bottomPlatform.fixtureDef);
		bottomPlatform.body.setUserData(bottomPlatform.id);
		
	}

    public function update(state:GameState, gameTime:GameTime):Void {
        playerController.update(state.player, gameTime);
		physicsController.update();
    }
	

	
}
