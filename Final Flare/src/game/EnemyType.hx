package game;
import box2D.common.math.B2Vec2;

/**
 * @author Sophie Huang
 */
class EnemyType
{
    public var spawnCooldown:Int;
    public var damageType:Int;
    public var health: Int;
    public var headOffset:B2Vec2 = new B2Vec2();
    public var maxMoveSpeed: Float;
    public var groundAcceleration: Float;
    public var airAcceleration: Float;

    public function new(cooldown:Int, damageT:Int, hp: Int, hdOffset:B2Vec2, maxSpeed: Float, gndAcc: Float, airAcc: Float) {
        spawnCooldown = cooldown;
        damageType = damageT;
        health = hp;
        headOffset.setV(hdOffset);
        maxMoveSpeed = maxSpeed;
        groundAcceleration = gndAcc;
        airAcceleration = airAcc;

    }
    public static function make( id:String ) {
        return switch (id) {
            case "Grunt": new game.EnemyType(
                //spawnCooldown
                360,
                //damageType
                0,
                //health
                50,
                //headOffset
                new B2Vec2(0, 0.6),
                //maxMoveSpeed
                7,
                //groundAcceleration
                0.9,
                //airAcceleration
                0.3);
            case "Shooter": new game.EnemyType(
                //spawnCooldown
                360,
                //damageType
                1,
                //health
                50,
                //headOffset
                new B2Vec2(0, 0.6),
                //maxMoveSpeed
                7,
                //groundAcceleration
                0.9,
                //airAcceleration
                0.3);
            case "Tank": new game.EnemyType(
                //spawnCooldown
                360,
                //damageType
                0,
                //health
                250,
                //headOffset
                new B2Vec2(0, 0.6),
                //maxMoveSpeed
                7,
                //groundAcceleration
                0.9,
                //airAcceleration
                0.3);
            default: throw 'unknown enemy type!';
        }
    }
}