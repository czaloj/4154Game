package;

import box2D.dynamics.B2DebugDraw;
import openfl.geom.Point;
import box2D.dynamics.contacts.B2Contact;
import box2D.dynamics.B2ContactListener;
import box2D.common.math.B2Vec2;
import box2D.dynamics.B2World;
import flash.display.Sprite;
import openfl.Lib;

class PhysicsController extends B2ContactListener {
    public static var GRAVITY = new B2Vec2(0,-160);

    public var world:B2World;
    public var debugger: B2DebugDraw;

    public function new() {
        super();

        world = new B2World(GRAVITY, true);
        world.setContactListener(this);
        world.setWarmStarting(true);
    }

    /**
     * Setup debugging information
     * @param sprite The target drawing sprite
     */
    public function initDebug(sprite:openfl.display.Sprite) {
        var dbgDraw:B2DebugDraw = new B2DebugDraw();
        dbgDraw.setSprite(sprite);
        dbgDraw.setDrawScale(1.0);
        dbgDraw.setFillAlpha(0.3);
        dbgDraw.setLineThickness(1.0);
        dbgDraw.setFlags(B2DebugDraw.e_shapeBit | B2DebugDraw.e_jointBit);
        world.setDebugDraw(dbgDraw);
    }

    public function BeginContact(contact:B2Contact):Void {
        // Check what was in collision
        var entity1 = contact.getFixtureA().getBody().getUserData();
        var entity2 = contact.getFixtureB().getBody().getUserData();
        trace(entity1);
        trace(entity2);

        // TODO: Just enqueue something into the state for the GameplayController to process
    }

    public function update(dt:Float) {
        world.step(dt, 8, 5);
        world.clearForces();
        world.drawDebugData();
    }
}