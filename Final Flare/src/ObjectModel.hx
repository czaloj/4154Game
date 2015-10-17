package;

import box2D.dynamics.B2Body;
import box2D.dynamics.B2BodyDef;
import box2D.dynamics.B2BodyType;
import box2D.dynamics.B2Fixture;
import box2D.dynamics.B2FixtureDef;
import box2D.common.math.B2Vec2;
import box2D.collision.shapes.B2Shape;
import box2D.collision.shapes.B2PolygonShape;
import openfl.geom.Point;

class ObjectModel {

    public var id:String;          //Identifying tag

    //Phsyics data
    public var shape:B2PolygonShape; 
    public var body:B2Body;
    public var bodyType:B2BodyType;
    public var bodyDef:B2BodyDef;
    public var fixture:B2Fixture;
    public var fixtureDef:B2FixtureDef;
    public var gravityScale:Float;
    public var width:Float;        //In case body dimensions are different from the sprite dimensions
    public var height:Float;       //In case body dimensions are different from the sprite dimensions
    public var position:B2Vec2 = new B2Vec2();     //Object position
    public var velocity:B2Vec2 = new B2Vec2();     //Object velocity
    public var rotation:Float;                   //Rotation

    //Drawing Fields
    public var textureSize:Point = new Point();  //Texture Size
    public var dimension:Point = new Point();    //Dimensions of box, for drawing purposes
    public var scale:Point = new Point();        //Used to scale texture

    //Input Flags
    public var direction:Int;      //-1 for left, 1 for right, 0 otherwise
    public var canShoot:Bool;
    public var canJump:Bool;
    public var left:Bool;          //Can move left
    public var right:Bool;         //Can move right
    public var up:Bool;            //up is being pressed
    public var down:Bool;  
    public var grounded:Bool;      //True if touching a platform
	public var isDead:Bool; //True is player is dead
	
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
        // Empty
    }
}
