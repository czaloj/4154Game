package game;

import game.events.GameEventSpawn;
import game.GameplayController;
import game.GameState;
import openfl.geom.Point;
import weapon.WeaponGenerator;

class Spawner {
    public static var PLAYER_MAX_SPEED:Float = 7;
    public static var PLAYER_GROUND_ACCEL:Float = .9;
    public static var PLAYER_AIR_ACCEL:Float = .3;

    public var id:String; // Identifying tag
    public var position:Point = new Point(); // Spawner position

    public function new(id:String = null, x:Float = 0, y:Float = 0) {
        this.id = id;
        position.x = x;
        position.y = y;
    }
    public static function spawn(state: GameState, gameTime:GameTime) {
        // TODO: Use advanced spawning logic
        // TODO: factor in difficulty
        var spawnCount:Int = 0;
        for (spawner in state.spawners) {
            if ((state.entities.length + spawnCount - 5) < 100) {
                var type = EnemyType.make(spawner.id);
                if (gameTime.frame % (type.spawnCooldown - 50 * Std.int(Math.log(state.score))) == 201) {
                    state.gameEvents.push(new GameEventSpawn(spawner.position.x, spawner.position.y, spawner.id));
                    spawnCount++;
                }
            }
        }
    }

    public static function createPlayer(e:Entity, type:String, x:Float, y:Float):Void {
        e.id = type;
        e.team = Entity.TEAM_PLAYER;
        e.health = 100;
        e.damageTimer = GameplayController.INVINCIBILITY_TIME;

        // Physical parameters
        e.position.set(x, y);
        e.velocity.set(0, 0);
        e.width = 0.8;
        e.height = 1.9;
        e.headOffset.set(0, 0.6);
        e.maxMoveSpeed = 7;
        e.groundAcceleration = 0.9;
        e.airAcceleration = 0.3;

        // Clear flags
        e.direction = 0;
        e.up = false;
        e.useWeapon = false;
        e.targetX = 0;
        e.targetY = 0;
        e.rightTouchingWall = 0;
        e.leftTouchingWall = 0;
        e.feetTouches = 0;
    }
    public static function createEnemy(e:Entity, type:String, x:Float, y:Float):Void {
        var enemyInfo = EnemyType.make(type);
        e.id = type;
        e.team = Entity.TEAM_ENEMY;
        e.health =enemyInfo.health;
        e.damageTimer = GameplayController.INVINCIBILITY_TIME;

        // Physical parameters
        e.position.set(x, y);
        e.velocity.set(0, 0);
        e.width = 0.9;
        e.height = 1.9;
        e.headOffset.set(0, 0.6);
        e.maxMoveSpeed = 5;
        e.groundAcceleration = 0.45;
        e.airAcceleration = 0.15;

        // Clear flags
        e.direction = 0;
        e.up = false;
        e.useWeapon = false;
        e.targetX = 0;
        e.targetY = 0;
        e.rightTouchingWall = 0;
        e.leftTouchingWall = 0;
        e.feetTouches = 0;
    }
}
