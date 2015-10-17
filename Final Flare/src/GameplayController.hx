package;

import openfl.display.Sprite;
import openfl.geom.Point;
import box2D.dynamics.B2Body;
import box2D.dynamics.B2BodyDef;
import box2D.dynamics.B2Fixture;
import box2D.dynamics.B2FixtureDef;
import box2D.collision.shapes.B2PolygonShape;
import box2D.common.math.B2Vec2;
import box2D.dynamics.B2DebugDraw;
import box2D.common.B2Color;
import box2D.dynamics.B2World;
import openfl.Lib;

class GameplayController {
    public static var PLAYER_MAX_SPEED:Float = 80;
    public static var PLAYER_GROUND_ACCEL:Float = 8.5;
    public static var PLAYER_AIR_ACCEL:Float = 6.5;
    public static var PLAYER_GROUND_FRICTION:Float = .3;
    public static var PLAYER_AIR_FRICTION:Float = .9;
    public static inline var TILE_HALF_WIDTH:Float = 16;

    private var platform:ObjectModel;
    private var physicsController:PhysicsController;
    private var debugPhysicsView:Sprite;

    public function new() {
        physicsController = new PhysicsController();
    }

    public function initDebug(debugPhysicsView:Sprite):Void {
        // Create a debug view of the physics world
        debugPhysicsView.x = ScreenController.SCREEN_WIDTH / 2;
        debugPhysicsView.y = ScreenController.SCREEN_HEIGHT / 2;
        debugPhysicsView.scaleY = -debugPhysicsView.scaleY;
        physicsController.initDebug(debugPhysicsView);
    }
    
    public function init(state:GameState):Void {
        createPlayer(physicsController.world, state.player);

        for (i in 0...(state.width * state.height)) {
            var x:Float = (i % state.width) * TILE_HALF_WIDTH + (TILE_HALF_WIDTH * 0.5);
            var y:Float = (state.height -  (Std.int(i / state.width) + 1)) * TILE_HALF_WIDTH + (TILE_HALF_WIDTH * 0.5);
            if (state.foreground[i] != 0) {
                // TODO: Platforms are not ObjectModels
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
                platform.bodyDef.position.set(platform.position.x, platform.position.y);
                platform.bodyDef.type = B2Body.b2_staticBody;

                var polygon = new B2PolygonShape ();
                polygon.setAsBox ((platform.width)/2, (platform.height)/2);

                platform.fixtureDef = new B2FixtureDef();
                platform.fixtureDef.shape = polygon;
                platform.body = physicsController.world.createBody(platform.bodyDef);
                platform.body.createFixture(platform.fixtureDef);
                platform.body.setUserData(platform.id);
            }
         }
    }

    // TODO: Remove this function from here
    public function createPlayer(world:B2World, player:ObjectModel):Void {
        //ALL THE MAGIC NUMBERS. REMEMBER TO FIX.
        player.id = "player";
        player.velocity.set(0,0);
        player.grounded = true;
        player.rotation = 0;
        player.left = false;
        player.right = false;
        player.dimension = new Point(32, 64);
        player.width = 32;
        player.height = 64;

        player.bodyDef = new B2BodyDef();
        player.bodyDef.position.set(player.position.x, player.position.y);
        player.bodyDef.type = B2Body.b2_dynamicBody;
		player.bodyDef.fixedRotation = true;

        player.shape = new B2PolygonShape();
        player.shape.setAsBox ((player.width)/2, (player.height)/2);

        player.fixtureDef = new B2FixtureDef();
        player.fixtureDef.shape = player.shape;
        player.fixtureDef.friction = 1;
        player.fixtureDef.density = 1;
        player.body = world.createBody(player.bodyDef);
        player.fixture = player.body.createFixture(player.fixtureDef);
        player.body.setUserData(player);
    }
	
	//TODO ADD ARGUMENTS FROM PARSER SO THAT RIGHT INFO IS USED
	public function createEnemy(world:B2World, enemy:ObjectModel) {
		enemy.id = "player";
        enemy.velocity.set(0,0);
        enemy.grounded = false;
        enemy.rotation = 0;
        enemy.left = false;
        enemy.right = false;
        enemy.dimension = new Point(32, 32);
        enemy.width = 32;
        enemy.height = 32;

        enemy.bodyDef = new B2BodyDef();
        enemy.bodyDef.position.set(enemy.position.x, enemy.position.y);
        enemy.bodyDef.type = B2Body.b2_dynamicBody;
		enemy.bodyDef.fixedRotation = true;

        enemy.shape = new B2PolygonShape();
        enemy.shape.setAsBox ((enemy.width)/2, (enemy.height)/2);

        enemy.fixtureDef = new B2FixtureDef();
        enemy.fixtureDef.shape = enemy.shape;
        enemy.fixtureDef.friction = 1;
        enemy.fixtureDef.density = 1;
        enemy.body = world.createBody(enemy.bodyDef);
        enemy.fixture = enemy.body.createFixture(enemy.fixtureDef);
        enemy.body.setUserData(enemy);
		
	}
	/*
	 * <code>function Callback(fixture:B2Fixture,    // The fixture hit by the ray
	 * point:B2Vec2,         // The point of initial intersection
	 * normal:B2Vec2,        // The normal vector at the point of intersection
	 * fraction:Float       // The fractional length along the ray of the intersection
	 * ):Float
	 * </code>
	 */
	public dynamic function raycastReporter(fixture:B2Fixture, point:B2Vec2, normal:B2Vec2, fraction:Float):Float {
		if (fixture.getBody().getUserData() != null)
		{
			var o = fixture.getBody().getUserData();
			cast(o, ObjectModel);
			if (o.id == "platform")
			{
				return fraction;
			}
			else
			{
				return 0;
			}
		}
		return -1;
	}
	
	public function Raycast(world:B2World, o:ObjectModel):Void {
	//Left foot raycast
	o.leftFootGrounded = false;
	//o.rightFootGrounded = false;
	//o.leftTouchingWall  = false;
	//o.rightTouchingWall =  false;	
	world.rayCast(raycastReporter, o.leftRayStart, o.leftRayEnd);
	//world.rayCast(raycastReporter, o.rightRayStart, o.rightRayEnd);
	//world.rayCast(raycastReporter, o.leftWallRayStart, o.leftWallRayEnd);
	//world.rayCast(raycastReporter, o.rightWallRayStart, o.rightWallRayEnd);
	
	}	
	
	public function handleCollisions(entity1: ObjectModel, entity2: ObjectModel) :Bool
	{
		//You can walk through enemies
		if (entity1.id == "player" && entity2.id == "enemy" || entity1.id == "enemy" && entity2.id == "player") {		
			return false;
		}
		
		return false;
	}

    public function update(state:GameState, gameTime:GameTime):Void {
        //UPDATES VELOCITY
        state.player.velocity = state.player.body.getLinearVelocity(); //Just in case -__-
        var moveSpeed = state.player.grounded ? PLAYER_GROUND_ACCEL : PLAYER_AIR_ACCEL;
        if (state.player.left) state.player.velocity.x -= moveSpeed;
        if (state.player.right) state.player.velocity.x += moveSpeed;

        //Apply friction if there is no input command
        if (!state.player.left && !state.player.right) {
            var friction = state.player.grounded ? PLAYER_GROUND_FRICTION : PLAYER_AIR_FRICTION;
            state.player.velocity.x *= friction;
        }

        // Clamp speed to a maximum value
        state.player.velocity.x = Math.min(PLAYER_MAX_SPEED, Math.max(-PLAYER_MAX_SPEED, state.player.velocity.x));

        if (state.player.up && state.player.leftFootGrounded) {
                state.player.velocity.y = 70;
        }

        state.player.body.setLinearVelocity(state.player.velocity); //So that the velocity actually does something

        //UPDATE POSITION

        var levelWidth = state.width * TILE_HALF_WIDTH;
        var levelHeight = state.height * TILE_HALF_WIDTH;
        if (state.player.position.x > levelWidth - state.player.width / 2) state.player.position.x = levelWidth - state.player.width / 2;
        if (state.player.position.x < state.player.width / 2) state.player.position.x = state.player.width / 2;
        //if (state.player.position.y > 250) state.player.position = new B2Vec2(state.player.position.x,250);
        //if (state.player.position.y < -250) state.player.position = new B2Vec2(state.player.position.x, -250);

        physicsController.update(gameTime.elapsed);
        state.player.position = state.player.body.getPosition();
		
		//Update Raycast Rays
         //Update left Ray
		state.player.leftRayStart = new B2Vec2(state.player.position.x - state.player.width, state.player.position.y + state.player.height);
		state.player.leftRayEnd = new B2Vec2(state.player.leftRayStart.x, state.player.leftRayStart.y + 3);

		//Update right ray
		state.player.leftRayStart = new B2Vec2(state.player.position.x + state.player.width, state.player.position.y + state.player.height);
		state.player.rightRayEnd = new B2Vec2(state.player.rightRayStart.x, state.player.rightRayStart.y + 3);

		//Update left wall Ray
		state.player.leftWallRayStart = new B2Vec2(state.player.position.x - state.player.width, state.player.position.y + state.player.height);
		state.player.leftWallRayEnd = new B2Vec2(state.player.leftWallRayStart.x -3, state.player.leftWallRayStart.y);

		//Update right wall ray
		state.player.rightWallRayStart = new B2Vec2(state.player.position.x - state.player.width, state.player.position.y + state.player.height);
		state.player.rightWallRayEnd = new B2Vec2(state.player.rightWallRayStart.x + 3, state.player.rightWallRayStart.y);
    }
}
