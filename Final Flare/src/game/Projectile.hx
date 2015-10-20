package game;

class Projectile extends Entity {
    private static var BULLET_SPEED:Float = 20;

    public var targetX:Float;
    public var targetY:Float;
    public var playerX:Float;
    public var playerY:Float;    
    public var deltaX:Float;
    public var deltaY:Float;
    public var magnitude:Float;
    public var rotation:Float;

    public var gravityScale:Float;
    
    public function new() {
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
    }
}
