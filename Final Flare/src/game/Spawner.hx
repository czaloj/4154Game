package game;

import game.events.GameEventSpawn;
import game.GameplayController;
import game.GameState;
import openfl.geom.Point;

class Spawner {
    public var id:String; // Identifying tag
    public var position:Point = new Point(); // Spawner position

    public function new(id:String = null, x:Float = 0, y:Float = 0) {
        this.id = id;
        position.x = x;
        position.y = y;
    }
    public static function spawn(gameplayController:game.GameplayController, state: game.GameState, gameTime:GameTime) {
        // TODO: Use advanced spawning logic
        var spawnCooldown;
        for (spawner in state.spawners) {
            var type = game.EnemyType.make(spawner.id);
            //TODO: factor in difficulty
            if (gameTime.frame % type.spawnCooldown <= state.score/10) {
                state.gameEvents.push(new GameEventSpawn(spawner.position.x, spawner.position.y, spawner.id));
            }
        }
    }

    public static function createPlayer(e:Entity, type:String, x:Float, y:Float):Void {
        e.id = "player";
        e.health = 100;

        // Physical parameters
        e.position.set(x, y);
        e.velocity.set(0, 0);
        e.width = 0.9;
        e.height = 1.9;

        e.left = false;
        e.right = false;
    }
    public static function createEnemy(e:Entity, type:String, x:Float, y:Float):Void {
        e.id = "enemy";
        e.health = 50;

        // Physical parameters
        e.position.set(x, y);
        e.velocity.set(0, 0);
        e.width = 0.9;
        e.height = 1.9;

        e.left = false;
        e.right = false;
    }
}
