package game;

/**
 * @author Sophie Huang
 */
class EnemyType
{
    public var spawnCooldown:Int;
    public var damageType:Int;

    public function new(cooldown:Int, damageT:Int) {
        spawnCooldown = cooldown;
        damageType = damageT;
    }
    public static function make( id:String ) {
        return switch (id) {
            case "Grunt": new game.EnemyType(120, 0);
            default: throw 'unknown enemy type!';
        }
    }
}
