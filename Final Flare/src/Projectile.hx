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


class Projectile {
    
	private static var BULLET_SPEED:Float = 200;
    private static var PHYSICS_SCALE:Float = 1 / 30;
    public var id:String;
	
	public var targetX:Float;
    public var targetY:Float;
	public var playerX:Float;
    public var playerY:Float;
	public var deltaX:Float;
	public var deltaY:Float;
	public var magnitude:Float;
	
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
	
	
	public var textureSize:Point = new Point();  //Texture Size
    public var dimension:Point = new Point();    //Dimensions of box, for drawing purposes
    public var scale:Point = new Point();        //Used to scale texture
	
	
	
    public function new() 
    {
       
    }
	
	public function setVelocity():Void {
		
		deltaX = targetX - position.x;
		deltaY = targetY - position.y;
		magnitude = Math.sqrt(deltaX * deltaX + deltaY * deltaY);
		deltaX = deltaX / magnitude;
		deltaY = deltaY / magnitude;
		deltaX = deltaX * BULLET_SPEED;
		deltaY = deltaY * BULLET_SPEED;
		velocity.x = deltaX;
		velocity.y = deltaY;
		//body.setLinearVelocity(velocity);
		
	}

    
    
    
}
