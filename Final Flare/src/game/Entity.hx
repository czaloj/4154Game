package game;

import box2D.dynamics.B2Body;
import box2D.dynamics.B2BodyDef;
import box2D.dynamics.B2BodyType;
import box2D.dynamics.B2Fixture;
import box2D.dynamics.B2FixtureDef;
import box2D.common.math.B2Vec2;
import box2D.collision.shapes.B2Shape;
import box2D.collision.shapes.B2PolygonShape;
import game.damage.DamagePolygon;
import openfl.geom.Point;
import weapon.Weapon;

class Entity extends EntityBase {
    public static inline var TEAM_PLAYER:Int = 0;
    public static inline var TEAM_ENEMY:Int = 1;

    public var id:String; // Identifying tag

    // Gameplay physical data
    public var width:Float;        // The collision size of the entity
    public var height:Float;       // The collision size of the entity
    public var position:B2Vec2 = new B2Vec2();     // Object position
    public var velocity:B2Vec2 = new B2Vec2();     // Object velocity
    public var headOffset:B2Vec2 = new B2Vec2();
    public var headAngle:Float = 0.0;
    public var weaponOffset:B2Vec2 = new B2Vec2();
    public var weaponAngle:Float = 0.0;
    public var lookingDirection(get, never):Float; // The direction the entity is facing (1.0 for right, -1.0 for left)
    public var maxMoveSpeed:Float = 1.0;
    public var groundAcceleration:Float = 1.0;
    public var airAcceleration:Float = 1.0;

    // Other Logical information
    public var team:Int;
    public var enabled:Bool = true;
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
    public var up:Bool; // Jump up is being pressed
    public var useWeapon:Bool; // Entity desires to use the weapon
    public var targetX:Float; // The location the entity is targeting (X)
    public var targetY:Float; // The location the entity is targeting (Y)

    // Physics flags
    public var feetTouches:Int = 0;
    public var isGrounded(get, never):Bool;
    public var leftTouchingWall:Int = 0;
    public var rightTouchingWall:Int = 0;

    public var damage:DamagePolygon;

    public function new() {
        super();
        damage = new DamagePolygon();
        damage.damage = 5;
        damage.x = 0;
        damage.y = 0;
        damage.setParent(this, false);
    }

    public function get_isGrounded():Bool {
        return feetTouches > 0;
    }
    public function get_isDead():Bool {
        return health < 0;
    }
    public function get_lookingDirection():Float {
        return position.x < targetX ? 1.0 : -1.0;
    }
}
