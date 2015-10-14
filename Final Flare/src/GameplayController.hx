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

        player.shape = new B2PolygonShape();
        player.shape.setAsBox ((player.width)/2, (player.height)/2);

        player.fixtureDef = new B2FixtureDef();
        player.fixtureDef.shape = player.shape;
        player.fixtureDef.friction = 1;
        player.fixtureDef.density = 1;
        player.body = world.createBody(player.bodyDef);
        player.fixture = player.body.createFixture(player.fixtureDef);
        player.body.setUserData("player");
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

        if (state.player.up) {
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
        
        trace(state.player.position.x, state.player.position.y);
    }
}
