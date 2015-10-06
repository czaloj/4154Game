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
    public static inline var TILE_HALF_WIDTH:Float = 16;
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
         for (i in 0...state.foreground.length) {
            var x:Float = (i % state.width) * TILE_HALF_WIDTH - state.width * TILE_HALF_WIDTH * 0.5;
            var y:Float = (state.height -  (Std.int(i / state.width) + 1)) * TILE_HALF_WIDTH - state.height * TILE_HALF_WIDTH * 0.5;
            if (state.foreground[i] != 0) {
                var platform = new ObjectModel();
                platform.id = "platform";
                platform.position.set(x, y);
                platform.grounded = false;
                platform.rotation = 0;
                platform.velocity.set(0,0);
                platform.left = false;
                platform.right = false;
                platform.height = TILE_HALF_WIDTH;
                platform.width = TILE_HALF_WIDTH;

                platform.bodyDef = new B2BodyDef();
                platform.bodyDef.position.set(platform.position.x * PHYSICS_SCALE, platform.position.y * PHYSICS_SCALE);
                platform.bodyDef.type = B2Body.b2_staticBody;

                var polygon = new B2PolygonShape ();
                polygon.setAsBox ((platform.width / 2) * PHYSICS_SCALE, (platform.height / 2) * PHYSICS_SCALE);
                //trace(polygon.getVertices());

                platform.fixtureDef = new B2FixtureDef();
                platform.fixtureDef.shape = polygon;
                platform.body = physicsController.world.createBody(platform.bodyDef);
                platform.body.createFixture(platform.fixtureDef);
                platform.body.setUserData(platform.id);
            }
         }

	}

    public function update(state:GameState, gameTime:GameTime):Void {
        playerController.update(state.player, gameTime);
		physicsController.update();
        trace(state.player.position.x);
        trace(state.player.position.y);
    }
}
