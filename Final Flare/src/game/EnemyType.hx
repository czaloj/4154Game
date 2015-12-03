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
    public var weaponOffset:B2Vec2 = new B2Vec2();
    public var maxMoveSpeed: Float;
    public var groundAcceleration: Float;
    public var airAcceleration: Float;
    public var attackFrom: Float;
    public var standFrom: Float;

    public function new(cooldown:Int, damageT:Int, hp: Int, hdOffset:B2Vec2, wOff:B2Vec2, maxSpeed: Float, gndAcc: Float, airAcc: Float, attFrom: Float, stFrom:Float) {
        spawnCooldown = cooldown;
        damageType = damageT;
        health = hp;
        headOffset.setV(hdOffset);
        weaponOffset.setV(wOff);
        maxMoveSpeed = maxSpeed;
        groundAcceleration = gndAcc;
        airAcceleration = airAcc;
        attackFrom = attFrom;
        standFrom = stFrom;

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
                new B2Vec2(0.3, 0.0),
                //maxMoveSpeed
                6,
                //groundAcceleration
                0.8,
                //airAcceleration
                0.3,
                //attackFrom
                5,
                //standFrom
                3);
            case "Shooter": new game.EnemyType(
                //spawnCooldown
                360,
                //damageType
                1,
                //health
                50,
                //headOffset
                new B2Vec2(0, 0.6),
                new B2Vec2(0.4, 0.2),
                //maxMoveSpeed
                7,
                //groundAcceleration
                0.9,
                //airAcceleration
                0.3,
                //attackFrom
                10,
                //standFrom
                10);
            case "Tank": new game.EnemyType(
                //spawnCooldown
                360,
                //damageType
                0,
                //health
                250,
                //headOffset
                new B2Vec2(0, 0.6),
                new B2Vec2(0.4, 0.2),
                //maxMoveSpeed
                4,
                //groundAcceleration
                0.6,
                //airAcceleration
                0.3,
                //attackFrom
                2,
                //standFrom
                1);
            case "Boss": new game.EnemyType(
                //spawnCooldown
                360,
                //damageType
                0,
                //health
                1500,
                //headOffset
                new B2Vec2(0, 0.6),
                new B2Vec2(0.4, 0.2),
                //maxMoveSpeed
                3,
                //groundAcceleration
                0.5,
                //airAcceleration
                0.3,
                //attackFrom
                2,
                //standFrom
                1);
                
            default: throw 'unknown enemy type!';
        }
    }
}