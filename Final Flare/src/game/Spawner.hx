package game;

import game.events.GameEventSpawn;
import game.GameplayController;
import game.GameState;
import graphics.Renderer;
import openfl.display.Graphics;
import openfl.geom.Point;
import openfl.events.EventDispatcher;

class Spawner {
    public var id:String; // Identifying tag

    //Physics data
    public var position:Point = new Point(); // Spawner position

    public function new(id:String = null, x:Float = 0, y:Float = 0) {
        this.id = id;
        position.x = x;
        position.y = y;
    }
    public static function spawn(gameplayController:game.GameplayController, state: game.GameState, gameTime:GameTime) {
        // TODO: Use advanced spawning logic
        if (gameTime.frame % 120 == 0) {
            for (spawner in state.spawners) {
                state.gameEvents.push(new GameEventSpawn(spawner.position.x, spawner.position.y, "Grunt"));
            }
        }
     }
}
