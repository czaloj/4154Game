package game;

import box2D.collision.shapes.B2PolygonShape;
import box2D.common.math.B2Vec2;
import box2D.dynamics.B2Body;
import box2D.dynamics.B2BodyDef;
import box2D.dynamics.B2DebugDraw;
import box2D.dynamics.B2FixtureDef;
import box2D.dynamics.B2World;
import flash.display.Sprite;
import game.GameState;
import game.ObjectModel;

class PhysicsController {
    public static var GRAVITY = new B2Vec2(0, -9.8);
    public static inline var DEBUG_VIEW_SCALE:Float = 32;
    
    public var world:B2World;
    private var state:game.GameState;
    private var contactListener:ContactListener;
    private var contactFilter:ContactFilter;
    public var debugger: B2DebugDraw;

    public function new(s:game.GameState) {
        init(s);
    }
    
    public function init(s:game.GameState) {
        state = s;
        world = new B2World(GRAVITY, true);
        contactListener = new ContactListener( state);
        world.setContactListener(contactListener);
        contactFilter = new ContactFilter(state);
        world.setContactFilter(contactFilter);
        world.setWarmStarting(true);
    }

    /**
     * Setup debugging information
     * @param sprite The target drawing sprite
     */
    public function initDebug(sprite:openfl.display.Sprite) {
        var dbgDraw:B2DebugDraw = new B2DebugDraw();
        dbgDraw.setSprite(sprite);
        dbgDraw.setDrawScale(DEBUG_VIEW_SCALE);
        dbgDraw.setFillAlpha(0.3);
        dbgDraw.setLineThickness(1.0);
        dbgDraw.setFlags(B2DebugDraw.e_shapeBit | B2DebugDraw.e_jointBit);
        world.setDebugDraw(dbgDraw);
    }

    public function initEntity(e:ObjectModel):Void {
        // Create body
        e.bodyDef = new B2BodyDef();
        e.bodyDef.position.set(e.position.x, e.position.y);
        e.bodyDef.type = B2Body.b2_dynamicBody;
        e.bodyDef.allowSleep = false;
        e.bodyDef.fixedRotation = true;
        e.body = world.createBody(e.bodyDef);

        // Create collision information
        e.shape = new B2PolygonShape();
        e.shape.setAsBox ((e.width) / 2, (e.height) / 2);
        e.fixtureDef = new B2FixtureDef();
        e.fixtureDef.shape = e.shape;
        e.fixtureDef.friction = 1;
        e.fixtureDef.density = 1;
        e.fixture = e.body.createFixture(e.fixtureDef);
        
        // Set initial entity data to the body
        e.body.setUserData(e);
        e.body.setLinearVelocity(e.velocity);
    }
    public function initPlatforms(state:GameState):Void { 
        var halfSize:Float = GameplayController.TILE_HALF_WIDTH;
        
        for (i in 0...(state.width * state.height)) {
            var x:Float = (i % state.width) * halfSize + (halfSize * 0.5);
            var y:Float = (state.height -  (Std.int(i / state.width) + 1)) * halfSize + (halfSize * 0.5);
            if (state.foreground[i] != 0) {
                // TODO: Platforms are not ObjectModels
                var platform = new ObjectModel();

                platform.id = "platform";
                platform.position.set(x, y);
                platform.grounded = false;
                platform.velocity.set(0,0);
                platform.left = false;
                platform.right = false;
                platform.height = halfSize;
                platform.width = halfSize;

                platform.bodyDef = new B2BodyDef();
                platform.bodyDef.position.set(platform.position.x, platform.position.y);
                platform.bodyDef.type = B2Body.b2_staticBody;

                var polygon = new B2PolygonShape ();
                polygon.setAsBox ((platform.width)/2, (platform.height)/2);

                platform.fixtureDef = new B2FixtureDef();
                platform.fixtureDef.shape = polygon;
                platform.body = world.createBody(platform.bodyDef);
                platform.body.createFixture(platform.fixtureDef);
                platform.body.setUserData(platform);
            }
         }
    }
    
    public function update(dt:Float) {
        world.step(1 / 60, 5, 3);
        for (entity in state.markedForDeletion) {
                world.destroyBody(entity.body);
                if (entity.id == "enemy") {
                var ontity = cast(entity, game.ObjectModel);    
                state.entities.remove(ontity);
                }
                
        }
        world.clearForces();
        world.drawDebugData();
    }
}