package game;

/**
 * @author Sophie Huang
 */
class EnemyType
{
    public var spawnCooldown:Int;
    public var damageType:Int;
    public var health: Int;

    public function new(cooldown:Int, damageT:Int, hp: Int) {
        spawnCooldown = cooldown;
        damageType = damageT;
        health = hp;
    }
    public static function make( id:String ) {
        return switch (id) {
            case "Grunt": new game.EnemyType(360, 0, 50);
            case "Shooter": new game.EnemyType(360, 1, 50);
            case "Tank": new game.EnemyType(360, 0, 250);
            default: throw 'unknown enemy type!';
        }
    }
}
