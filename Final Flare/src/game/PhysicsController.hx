package game;

import box2D.collision.shapes.B2PolygonShape;
import box2D.common.math.B2Vec2;
import box2D.dynamics.B2Body;
import box2D.dynamics.B2BodyDef;
import box2D.dynamics.B2ContactListener;
import box2D.dynamics.B2DebugDraw;
import box2D.dynamics.B2FilterData;
import box2D.dynamics.B2Fixture;
import box2D.dynamics.B2FixtureDef;
import box2D.dynamics.B2World;
import box2D.dynamics.contacts.B2Contact;
import box2D.dynamics.joints.B2DistanceJointDef;
import flash.display.Sprite;
import game.GameState;
import game.Entity;
import game.PhysicsController.PhysicsContactBody;
import game.PhysicsController.PhysicsUserData;
import game.RayCastContext.RayCastInstance;

// Collided fixture, ray origin, collision point, normal
typedef RayCastInfo = Tuple4<B2Fixture, B2Vec2, B2Vec2, B2Vec2>;

// User data for fixtures
enum PhysicsUserDataType {
    ENTITY;
    PLATFORM;
}
typedef PhysicsUserData = Pair<PhysicsUserDataType, Dynamic>;

// Converted data
typedef PhysicsContactBody = Tuple3<PhysicsUserDataType, Dynamic, B2Fixture>;
class PhysicsContact {
    public var object1:PhysicsContactBody;
    public var object2:PhysicsContactBody;
    public var collisionNormal:B2Vec2 = new B2Vec2();
    public var isBegin:Bool = true;
    
    public function new() {
        // Empty
    }
}

class PhysicsController extends B2ContactListener {
    public static var GRAVITY = new B2Vec2(0, -9.8);
    public static inline var DEBUG_VIEW_SCALE:Float = 32;

    private static inline var FILTER_CATEGORY_PLAYER:Int = 0x1 << 0;
    private static inline var FILTER_CATEGORY_ENEMY:Int = 0x1 << 1;
    private static inline var FILTER_CATEGORY_PLATFORM:Int = 0x1 << 2;
    private static inline var FILTER_CATEGORY_PLAYER_DAMAGE:Int = 0x1 << 3;
    private static inline var FILTER_CATEGORY_ENEMY_DAMAGE:Int = 0x1 << 4;
    private static inline var FILTER_CATEGORY_NEUTRAL_DAMAGE:Int = 0x1 << 5;
    private static inline var FILTER_CATEGORY_PHYSICAL_PROJECTILE:Int = 0x1 << 5;

    private static var FILTER_PLAYER:B2FilterData = {
        var fd:B2FilterData = new B2FilterData();
        fd.categoryBits = FILTER_CATEGORY_PLAYER;
        fd.maskBits = FILTER_CATEGORY_PLATFORM | FILTER_CATEGORY_ENEMY_DAMAGE | FILTER_CATEGORY_NEUTRAL_DAMAGE;
        fd.groupIndex = 0;
        fd;
    }
    private static var FILTER_ENEMY:B2FilterData = {
        var fd:B2FilterData = new B2FilterData();
        fd.categoryBits = FILTER_CATEGORY_ENEMY;
        fd.maskBits = FILTER_CATEGORY_PLATFORM | FILTER_CATEGORY_PLAYER_DAMAGE | FILTER_CATEGORY_NEUTRAL_DAMAGE;
        fd.groupIndex = 0;
        fd;
    }
    private static var FILTER_PLATFORM:B2FilterData = {
        var fd:B2FilterData = new B2FilterData();
        fd.categoryBits = FILTER_CATEGORY_PLATFORM;
        fd.maskBits = FILTER_CATEGORY_PLAYER | FILTER_CATEGORY_ENEMY | FILTER_CATEGORY_PHYSICAL_PROJECTILE;
        fd.groupIndex = 0;
        fd;
    }
    private static var FILTER_PLAYER_DAMAGE:B2FilterData = {
        var fd:B2FilterData = new B2FilterData();
        fd.categoryBits = FILTER_CATEGORY_PLAYER_DAMAGE;
        fd.maskBits = FILTER_CATEGORY_PLATFORM | FILTER_CATEGORY_ENEMY;
        fd.groupIndex = 0;
        fd;
    }
    private static var FILTER_ENEMY_DAMAGE:B2FilterData = {
        var fd:B2FilterData = new B2FilterData();
        fd.categoryBits = FILTER_CATEGORY_ENEMY_DAMAGE;
        fd.maskBits = FILTER_CATEGORY_PLATFORM | FILTER_CATEGORY_PLAYER;
        fd.groupIndex = 0;
        fd;
    }
    private static var FILTER_NEUTRAL_DAMAGE:B2FilterData = {
        var fd:B2FilterData = new B2FilterData();
        fd.categoryBits = FILTER_CATEGORY_NEUTRAL_DAMAGE;
        fd.maskBits = FILTER_CATEGORY_ENEMY | FILTER_CATEGORY_PLAYER;
        fd.groupIndex = 0;
        fd;
    }

    public var world:B2World;
    public var state:GameState;
    public var debugger: B2DebugDraw;

    public var deleteList:Array<B2Body> = []; // List of entities that are marked for deletion

    private var rcContext:RayCastContext = null;

    public function new() {
        super();
    }

    public function init(s:GameState) {
        state = s;
        state.onEntityRemoved.add(onEntityRemoved);

        world = new B2World(GRAVITY, true);
        world.setContactListener(this);
        world.setWarmStarting(true);
    }

    public function initEntity(e:Entity):Void {
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
        switch (e.id) {
            case "player":
                e.fixtureDef.filter = FILTER_PLAYER.copy();
            default:
                e.fixtureDef.filter = FILTER_ENEMY.copy();
        }
        e.fixture = e.body.createFixture(e.fixtureDef);

        // Set initial entity data to the body
        e.fixture.SetUserData(new PhysicsUserData(PhysicsUserDataType.ENTITY, e));
        e.body.setLinearVelocity(e.velocity);
    }
    public function initPlatforms(state:GameState):Void {
        var halfSize:Float = GameplayController.TILE_HALF_WIDTH;

        for (i in state.platforms) {
            var x:Float = (i.position.x) * halfSize + i.dimension.x * halfSize/2;
            var y:Float = (state.height - i.position.y) * halfSize - i.dimension.y * halfSize/2;

            if (i.id != 0) {
                // Create the body
                var bodyDef:B2BodyDef = new B2BodyDef();
                bodyDef.position.set(x, y);
                bodyDef.type = B2Body.b2_staticBody;
                var body:B2Body = world.createBody(bodyDef);

                // Create the box collision fixture
                var fixtureDef:B2FixtureDef = new B2FixtureDef();
                fixtureDef.filter = FILTER_PLATFORM.copy();
                var polygon = new B2PolygonShape ();
                polygon.setAsBox((i.dimension.x * halfSize) * 0.5, (i.dimension.y * halfSize) * 0.5);
                fixtureDef.shape = polygon;
                var fixture:B2Fixture = body.createFixture(fixtureDef);

                // Set platform user data
                fixture.SetUserData(new PhysicsUserData(PhysicsUserDataType.PLATFORM, null));
            }
        }
    }

    public function update(dt:Float) {
        world.step(dt, 5, 3);
        world.clearForces();
    }
    public function clearDeadBodies() {
        if (deleteList.length > 0) {
            for (body in deleteList) {
                world.destroyBody(body);
            }
            deleteList = [];
        }
    }

    override function beginContact(contact:B2Contact):Void {
        super.beginContact(contact);

        var c:PhysicsContact = new PhysicsContact();

        // Convert collision objects
        var f1Data:Dynamic = contact.getFixtureA().getUserData();
        c.object1 = new PhysicsContactBody(f1Data.first, f1Data.second, contact.getFixtureA());
        var f2Data:Dynamic = contact.getFixtureB().getUserData();
        c.object2 = new PhysicsContactBody(f2Data.first, f2Data.second, contact.getFixtureB());

        // Get collision normal
        c.collisionNormal.setV(contact.getManifold().m_localPlaneNormal);
        
        state.contactList.add(c);
    }
    override function endContact(contact:B2Contact):Void {
        super.endContact(contact);
        
        var c:PhysicsContact = new PhysicsContact();
        c.isBegin = false;

        // Convert collision objects
        var f1Data:Dynamic = contact.getFixtureA().getUserData();
        c.object1 = new PhysicsContactBody(f1Data.first, f1Data.second, contact.getFixtureA());
        var f2Data:Dynamic = contact.getFixtureB().getUserData();
        c.object2 = new PhysicsContactBody(f2Data.first, f2Data.second, contact.getFixtureB());

        // Get collision normal
        c.collisionNormal.setV(contact.getManifold().m_localPlaneNormal);
        
        state.contactList.add(c);
    }
    
    private function onEntityRemoved(state:GameState, e:Entity) {
        deleteList.push(e.body);
    }

    public function rayCastCollisions(ox:Float, oy:Float, dx:Float, dy:Float, hitPlayer:Bool, hitEnemies:Bool, pierce:Int):Pair<Array<RayCastInfo>, RayCastInfo> {
        // New ray context used for ray collisions
        rcContext = new RayCastContext();

        // Setup filtering
        rcContext.discardCategories = FILTER_CATEGORY_PLATFORM;
        if (hitPlayer) {
            if (hitEnemies) {
                rcContext.hitCategories = FILTER_CATEGORY_ENEMY | FILTER_CATEGORY_PLAYER;
            }
            else {
                rcContext.hitCategories = FILTER_CATEGORY_PLAYER;
            }
        }
        else {
            if (hitEnemies) {
                rcContext.hitCategories = FILTER_CATEGORY_ENEMY;
            }
            else {
                // Construct ray points
                var origin:B2Vec2 = new B2Vec2(ox, oy);
                var end:B2Vec2 = new B2Vec2(ox + dx, oy + dy);
                world.rayCast(onRayCastPierce, origin, end);
                var wi:RayCastInfo = (rcContext.hitWall == null) ? null : new RayCastInfo(rcContext.hitWall.first, origin, rcContext.hitWall.third, rcContext.hitWall.fourth);
                return new Pair<Array<RayCastInfo>, RayCastInfo>([], wi);
            }
        }

        // Construct ray points
        var origin:B2Vec2 = new B2Vec2(ox, oy);
        var end:B2Vec2 = new B2Vec2(ox + dx, oy + dy);

        var results = [];
        if (pierce > 0) {
            // Get closest N + 1
            rcContext.maxHits = pierce + 1;
            world.rayCast(onRayCastN, origin, end);
            for (f in rcContext.closestNFixtures) {
                results.push(new RayCastInfo(f.first, origin, f.third, f.fourth));
            }
        }
        else if (pierce == 0) {
            // Get all pierced
            world.rayCast(onRayCastPierce, origin, end);
            for (f in rcContext.piercedFixtures) {
                results.push(new RayCastInfo(f.first, origin, f.third, f.fourth));
            }
        }
        else {
            // Just raycast and get the nearest damage
            world.rayCast(onRayCastClosest, origin, end);
            if (rcContext.closestFixture != null) {
                results.push(new RayCastInfo(
                    rcContext.closestFixture.first,
                    origin,
                    rcContext.closestFixture.third,
                    rcContext.closestFixture.fourth
                    ));
            }
        }

        var wi:RayCastInfo = (rcContext.hitWall == null) ? null : new RayCastInfo(rcContext.hitWall.first, origin, rcContext.hitWall.third, rcContext.hitWall.fourth);

        return new Pair<Array<RayCastInfo>, RayCastInfo>(results, wi);
    }
    private function onRayCastHitDiscard(fixture:B2Fixture, location:B2Vec2, normal:B2Vec2, fraction:Float) {
        if ((fixture.m_filter.categoryBits & rcContext.discardCategories) != 0) {
            // Hit a wall return immediately
            rcContext.hitWall = new RayCastInstance(fixture, fraction, location, normal);
            return 0;
        }
        else {
            return -1;
        }
    }
    private function onRayCastClosest(fixture:B2Fixture, location:B2Vec2, normal:B2Vec2, fraction:Float):Float {
        if ((fixture.m_filter.categoryBits & rcContext.discardCategories) != 0) {
            // Hit a wall, shorten the ray and discard last best result
            rcContext.hitWall = new RayCastInstance(fixture, fraction, location, normal);
            rcContext.closestFixture = null;
            return fraction;
        }
        else if ((fixture.m_filter.categoryBits & rcContext.hitCategories) != 0) {
            // We obtained the best new result
            rcContext.closestFixture = new RayCastInstance(fixture, fraction, location, normal);
            return fraction;
        }
        else {
            // Ignore this intersection
            return -1;
        }
    }
    private function onRayCastN(fixture:B2Fixture, location:B2Vec2, normal:B2Vec2, fraction:Float):Float {
        if ((fixture.m_filter.categoryBits & rcContext.discardCategories) != 0) {
            // Hit a wall, shorten the ray and discard last results past wall
            rcContext.hitWall = new RayCastInstance(fixture, fraction, location, normal);
            rcContext.closestNFixtures = rcContext.closestNFixtures.filter(function (f:RayCastInstance):Bool {
                return f.second < fraction;
            });
            rcContext.farthestHitFraction = 0.0;

            // Reupdate farthest hit
            for (pair in rcContext.closestNFixtures) {
                if (pair.second > rcContext.farthestHitFraction) {
                    rcContext.farthestHitFraction = pair.second;
                }
            }
            rcContext.wallFraction = fraction;
            return fraction;
        }
        else if ((fixture.m_filter.categoryBits & rcContext.hitCategories) != 0) {
            if (rcContext.closestNFixtures.length < rcContext.maxHits) {
                // We know we're still within our bounds for getting hits
                rcContext.closestNFixtures.push(new RayCastInstance(fixture, fraction, location, normal));
                if (fraction > rcContext.farthestHitFraction) {
                    rcContext.farthestHitFraction = fraction;
                }

                // If we're at max capacity, return farthest hit location, otherwise allow hits up until the closest wall
                return (rcContext.closestNFixtures.length < rcContext.maxHits) ? rcContext.wallFraction : rcContext.farthestHitFraction;
            }
            else {
                var i:Int = 0;
                var fhf:Float = 0.0;

                // We must replace the farthest hit
                while (i < rcContext.closestNFixtures.length) {
                    if (rcContext.closestNFixtures[i].second == rcContext.farthestHitFraction) {
                        rcContext.closestNFixtures[i] = new RayCastInstance(fixture, fraction, location, normal);
                        break;
                    }
                    else if (fhf < rcContext.closestNFixtures[i].second) {
                        fhf = rcContext.closestNFixtures[i].second;
                    }
                    i++;
                }
                i++;

                // Keep checking for farthest hit location
                while (i < rcContext.closestNFixtures.length) {
                    if (fhf < rcContext.closestNFixtures[i].second) {
                        fhf = rcContext.closestNFixtures[i].second;
                    }
                    i++;
                }
                rcContext.farthestHitFraction = fhf;

                // We're at max capacity, return farthest hit location
                return rcContext.farthestHitFraction;
            }
        }
        else {
            // Ignore this value
            return -1;
        }
    }
    private function onRayCastPierce(fixture:B2Fixture, location:B2Vec2, normal:B2Vec2, fraction:Float):Float {
        if ((fixture.m_filter.categoryBits & rcContext.discardCategories) != 0) {
            // Hit a wall, shorten the ray and discard last results past wall
            rcContext.hitWall = new RayCastInstance(fixture, fraction, location, normal);
            rcContext.piercedFixtures = rcContext.piercedFixtures.filter(function (f:RayCastInstance):Bool {
                return f.second < fraction;
            });
            rcContext.wallFraction = fraction;
            return fraction;
        }
        else if ((fixture.m_filter.categoryBits & rcContext.hitCategories) != 0) {
            // We obtained a valid result
            rcContext.piercedFixtures.push(new RayCastInstance(fixture, fraction, location, normal));
            return rcContext.wallFraction;
        }
        else {
            return -1;
        }
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
    public function renderDebug():Void {
        world.drawDebugData();
    }
}