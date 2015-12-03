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
    public var turnedOn:Bool;
    public var id2:String; //trolly shit not necessary
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
            if (state.score < state.scoreThreshold) {
                    spawner.turnedOn = true;
            }
            if (state.score > state.scoreThreshold) {
                spawner.turnedOn = false;
            }
            if (!state.bossFought &&state.score>state.scoreThreshold) {
                state.spawners[0].id2 = "Boss";
                state.spawners[0].turnedOn = true;
                state.spawners[0].id = "Boss";
            }
            if ((state.entities.length + spawnCount - 5) < 100) {
                var type = EnemyType.make(spawner.id);
                if (spawner.turnedOn&&(gameTime.frame % (Math.max(5,type.spawnCooldown - 50 * Std.int(Math.log(state.score)))) == 0)) {
                    state.gameEvents.push(new GameEventSpawn(spawner.position.x, spawner.position.y, spawner.id));
                    spawnCount++;
                    if (spawner.id == "Boss"||spawner.id2 =="Boss")
                    {
                        state.spawners[0].turnedOn = false;
                        state.bossFought = true;
                    }
                }
            }
        }
    }
    

    public static function createPlayer(e:Entity, type:String, x:Float, y:Float):Void {
        e.id = type;
        e.team = Entity.TEAM_PLAYER;
        e.health = 100;
        e.invincibilityAfterHit = 0.5;
        e.damageTimer = e.invincibilityAfterHit;

        // Physical parameters
        e.position.set(x, y);
        e.velocity.set(0, 0);
        e.width = 0.8;
        e.height = 1.9;
        e.headOffset.set(0, 0.6);
        e.maxMoveSpeed = 7;
        e.groundAcceleration = 0.9;
        e.airAcceleration = 0.3;
        e.headAngle = 0.0;
        e.weaponAngle = 0.0;
        e.targetX = e.position.x;
        e.targetY = e.position.y;


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
        e.health = enemyInfo.health;
        e.invincibilityAfterHit = 0.0;
        e.damageTimer = e.invincibilityAfterHit;

        // Physical parameters
        e.position.set(x, y);
        e.velocity.set(0, 0);
        e.width = 0.9;
        e.height = 1.9;
        e.headOffset.setV(enemyInfo.headOffset);
        e.maxMoveSpeed = enemyInfo.maxMoveSpeed;
        e.groundAcceleration = enemyInfo.groundAcceleration;
        e.airAcceleration = enemyInfo.airAcceleration;

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
