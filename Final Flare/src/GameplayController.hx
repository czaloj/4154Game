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
	public static var PLAYER_MAX_SPEED:Float = 5;
	public static var PLAYER_GROUND_ACCEL:Float = .55;
	public static var PLAYER_AIR_ACCEL:Float = .35;
	public static var PLAYER_GROUND_FRICTION:Float = .3;
	public static var PLAYER_AIR_FRICTION:Float = .9;
	public static inline var TILE_HALF_WIDTH:Float = 16;

    private var playerController:PlayerController;
	private var physicsController:PhysicsController;

    public function new(state:GameState) {
        init(state);
    }

	public function init(state:GameState):Void
	{
		state.player = new ObjectModel();
		physicsController = new PhysicsController();
		state.player = createPlayer(physicsController.world);

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
	
	public function createPlayer(world:B2World):ObjectModel
	{
		//ALL THE MAGIC NUMBERS. REMEMBER TO FIX.
		var player:ObjectModel = new ObjectModel();
        player.id = "player";
        player.position.set(0, 0);
		player.velocity.set(0,0);
        player.grounded = true;
        player.rotation = 0;
        player.left = false;
        player.right = false;
		player.dimension = new Point(32, 64);
		player.width = 32;
		player.height = 64;
		
		player.bodyDef = new B2BodyDef();
		player.bodyDef.position.set(player.position.x * PHYSICS_SCALE, player.position.y * PHYSICS_SCALE);
		player.bodyDef.type = B2Body.b2_dynamicBody;
	 
		var polygon = new B2PolygonShape ();
		polygon.setAsBox ((player.width / 2) * PHYSICS_SCALE, (player.height / 2) * PHYSICS_SCALE);
	 
		player.fixtureDef = new B2FixtureDef();
		player.fixtureDef.shape = polygon;
		player.fixtureDef.density = .001; 
		player.body = world.createBody(player.bodyDef);
		player.body.createFixture(player.fixtureDef);
		player.body.setUserData("player");
		player.body.setPosition(player.position);
		
		return player;
	}

    public function update(state:GameState, gameTime:GameTime):Void {
        
	//UPDATES VELOCITY		
		state.player.velocity = state.player.body.getLinearVelocity(); //Just in case -__-
		
		//Ground Movement
        if (state.player.grounded)
        {
            if (state.player.left) {
                state.player.velocity.x = Math.max(-PLAYER_MAX_SPEED, state.player.velocity.x - PLAYER_GROUND_ACCEL);
            }
            else if (state.player.right) {
                state.player.velocity.x = Math.min(PLAYER_MAX_SPEED, state.player.velocity.x + PLAYER_GROUND_ACCEL);
            }
            else {
              state.player.velocity.x = state.player.velocity.x * PLAYER_GROUND_FRICTION;			  
            }
        }
        //Mid-air movement
        else {
            if (state.player.left) {
                state.player.velocity.x = Math.max(-PLAYER_MAX_SPEED, state.player.velocity.x - PLAYER_AIR_ACCEL);
            }
            else if (state.player.right) {
                state.player.velocity.x = Math.min(PLAYER_MAX_SPEED, state.player.velocity.x + PLAYER_AIR_ACCEL);
            }
            else {
              state.player.velocity.x = state.player.velocity.x * PLAYER_AIR_FRICTION;			  
            }
        }
		
		state.player.body.setLinearVelocity(state.player.velocity); //So that the velocity actually does something
		
	//UPDATE POSITION
		//state.player.position = state.player.body.getPosition();
		state.player.position = new B2Vec2(state.player.position.x + state.player.velocity.x, state.player.position.y + state.player.velocity.y);

		//var pos:B2Vec2 = player.body.getPosition();
		if (state.player.position.x > 400) state.player.position = new B2Vec2(400.0, state.player.position.y);
		if (state.player.position.x < -400) state.player.position = new B2Vec2(-400.0, state.player.position.y);		
		if (state.player.position.y > 250) state.player.position = new B2Vec2(state.player.position.x,250);
		if (state.player.position.y < -250) state.player.position = new B2Vec2(state.player.position.x, -250);
		
		physicsController.update();
		
		
		//SORRY
		/*var moveSpeed = 3;//player.grounded ? .55 : .35;
        if (player.left) player.velocity.x -= moveSpeed;
        if (player.right) player.velocity.x += moveSpeed;
		
        // It seems we want to do conditional friction?
        if (!player.left && !player.right && !player.up && !player.down) {
            var friction = player.grounded ? .3 : .85;
            player.velocity.x *= friction;
        }
        
        // Clamp speed to a maximum value		
        player.velocity.x = Math.min(ObjectModel.MAX_SPEED, Math.max( -ObjectModel.MAX_SPEED, player.velocity.x));*/
		
    }	
		
        
		

		

	

	
}
