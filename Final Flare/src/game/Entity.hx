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
import weapon.Weapon;

class Entity extends EntityBase {
    public var id:String; // Identifying tag

    // Gameplay physical data
    public var width:Float;        // The collision size of the entity
    public var height:Float;       // The collision size of the entity
    public var position:B2Vec2 = new B2Vec2();     // Object position
    public var velocity:B2Vec2 = new B2Vec2();     // Object velocity

    // Other Logical information
    public var health:Int;
    public var isDead(get, never):Bool; // True if player is dead
    public var weapon:Weapon; // Weapon that the entity is holding
    
    //Physics data
    public var body:B2Body; // The physics body
    public var fixtureMain:B2Fixture; // Main fixture for terrain collisions
    public var fixtureBody:B2Fixture; // Fixture for damage occuring to the body
    public var fixtureHead:B2Fixture; // Fixture for damage occuring to the head (headshots)
    
    //Input Flags
    public var direction:Int; //  Direction of desired lateral movement (-1 for left, 1 for right, 0 otherwise)
    public var canShoot:Bool;
    public var canJump:Bool;
    public var left:Bool;          // Can move left
    public var right:Bool;         // Can move right
    public var up:Bool; // Jump up is being pressed
    public var down:Bool;  
    public var useWeapon:Bool;
    public var targetX:Float;
    public var targetY:Float;
     
    // Physics flags
    public var feetTouches:Int = 0;
    public var isGrounded(get, never):Bool;
    public var leftTouchingWall:Int = 0;
    public var rightTouchingWall:Int = 0;
    
    public function new() {
        super();
    }
    
    public function get_isGrounded():Bool {
        return feetTouches > 0;
    }
    public function get_isDead():Bool {
        return health < 0;
    }
}
