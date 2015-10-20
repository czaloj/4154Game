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


class Projectile extends Entity {
    
    private static var BULLET_SPEED:Float = 20;
    private static var PHYSICS_SCALE:Float = 1 / 30;
    
    public var targetX:Float;
    public var targetY:Float;
    public var playerX:Float;
    public var playerY:Float;    
    public var deltaX:Float;
    public var deltaY:Float;
    public var magnitude:Float;

    public var gravityScale:Float;
    
    
    public function new() 
    {
       super();
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
