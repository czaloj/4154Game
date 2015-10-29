package game;

import box2D.dynamics.B2Body;
import box2D.dynamics.B2BodyDef;
import box2D.dynamics.B2BodyType;
import box2D.dynamics.B2Fixture;
import box2D.dynamics.B2FixtureDef;
import box2D.common.math.B2Vec2;
import box2D.collision.shapes.B2Shape;
import box2D.collision.shapes.B2PolygonShape;
import openfl.geom.Point;

class ObjectModel extends Entity {

    
    // TODO: OMG, we need a real "Gun" class
    public var health:Int;
    //Input Flags
    public var direction:Int;      //-1 for left, 1 for right, 0 otherwise
    public var canShoot:Bool;
    public var canJump:Bool;
    public var left:Bool;          //Can move left
    public var right:Bool;         //Can move right
    public var up:Bool;            //up is being pressed
    public var down:Bool;  
    public var grounded(get, never):Bool;      //True if touching a platform
    public var isDead:Bool;         //True is player is dead
    public var useWeapon:Bool;
    public var targetX:Float; // TODO: This should be a viewing direction
    public var targetY:Float;
     
    //Raycast flags
    public var leftFootGrounded:Bool;
    public var rightFootGrounded:Bool;
    public var leftTouchingWall:Bool;
    public var rightTouchingWall:Bool;
    
    //Raycast rays
    public var leftRayStart:B2Vec2 = new B2Vec2();
    public var leftRayEnd:B2Vec2 = new B2Vec2();
    public var rightRayStart:B2Vec2 = new B2Vec2();
    public var rightRayEnd:B2Vec2 = new B2Vec2();
    public var leftWallRayStart:B2Vec2 = new B2Vec2();
    public var leftWallRayEnd:B2Vec2 = new B2Vec2();
    public var rightWallRayStart:B2Vec2 = new B2Vec2();
    public var rightWallRayEnd:B2Vec2 = new B2Vec2();

    public function new() {
        super();
    }
    
    public function get_grounded():Bool {
        return leftFootGrounded || rightFootGrounded;
    }
}
