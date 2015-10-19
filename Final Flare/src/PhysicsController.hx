package;

import box2D.dynamics.B2ContactFilter;
import box2D.dynamics.B2DebugDraw;
import openfl.geom.Point;
import box2D.dynamics.contacts.B2Contact;
import box2D.dynamics.B2ContactListener;
import box2D.common.math.B2Vec2;
import box2D.dynamics.B2World;
import flash.display.Sprite;
import openfl.Lib;

class PhysicsController {
    public static var GRAVITY = new B2Vec2(0,-160);

    public var world:B2World;
    private var state:GameState;
	private var contactListener:ContactListener;
	private var contactFilter:ContactFilter;
    public var debugger: B2DebugDraw;

    public function new(s:GameState) {
		init(s);
	}
	
	public function init(s:GameState) {
		state = s;
        world = new B2World(GRAVITY, true);
		contactListener = new ContactListener(state);
        world.setContactListener(contactListener);
		contactFilter = new ContactFilter(state);
		world.setContactFilter(contactFilter);
        //world.setWarmStarting(true);
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
        //world.setDebugDraw(dbgDraw);
    }

    public function update(dt:Float) {
        world.step(dt, 8, 5);
        world.clearForces();
        world.drawDebugData();
    }
}