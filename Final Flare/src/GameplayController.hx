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
    public static var PLAYER_MAX_SPEED:Float = 5;
    public static var PLAYER_GROUND_ACCEL:Float = .55;
    public static var PLAYER_AIR_ACCEL:Float = .35;
    public static var PLAYER_GROUND_FRICTION:Float = .3;
    public static var PLAYER_AIR_FRICTION:Float = .9;
    public static inline var TILE_HALF_WIDTH:Float = 16;

    private var platform:ObjectModel;
    private var physicsController:PhysicsController;
    private var debugDraw:B2DebugDraw;

    public function new(state:GameState) {
        init(state);
    }

    public function init(state:GameState):Void
    {
        state.player = new ObjectModel();
        physicsController = new PhysicsController(state);
        var ws:Sprite = new Sprite();
        Lib.current.stage.addChild(ws);
        ws.x = ScreenController.SCREEN_WIDTH / 2;
        ws.y = ScreenController.SCREEN_HEIGHT / 2;
        ws.scaleY = -ws.scaleY;
        physicsController.initDebug(ws);
        state.player = createPlayer(physicsController.world);

        //Makes bottom platform. I'm unsure of the actual sizes
        platform = new ObjectModel();
        platform.id = "platform";
        platform.grounded = false;
        platform.rotation = 0;
        platform.position.set(-100, -150);
        platform.velocity.set(0,0);
        platform.left = false;
        platform.right = false;
        platform.height = 32;
        platform.width = 20000;

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


        /* for (i in 0...state.foreground.length) {
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
                polygon.setAsBox (platform.width * PHYSICS_SCALE, platform.height * PHYSICS_SCALE);

                platform.fixtureDef = new B2FixtureDef();
                platform.fixtureDef.shape = polygon;
                platform.body = physicsController.world.createBody(platform.bodyDef);
                platform.body.createFixture(platform.fixtureDef);
                platform.body.setUserData(platform.id);
            }
         }*/

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

        return player;
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
                state.player.velocity.y = 6;
        }

        state.player.body.setLinearVelocity(state.player.velocity); //So that the velocity actually does something

        //UPDATE POSITION
        state.player.body.setPosition(new B2Vec2(state.player.position.x + state.player.velocity.x, state.player.position.y + state.player.velocity.y));
        state.player.position = state.player.body.getPosition();

        //var pos:B2Vec2 = player.body.getPosition();
        if (state.player.position.x > 400) state.player.position = new B2Vec2(400.0, state.player.position.y);
        if (state.player.position.x < -400) state.player.position = new B2Vec2(-400.0, state.player.position.y);
        //if (state.player.position.y > 250) state.player.position = new B2Vec2(state.player.position.x,250);
        //if (state.player.position.y < -250) state.player.position = new B2Vec2(state.player.position.x, -250);

        physicsController.update(gameTime.elapsed);
    }
}
