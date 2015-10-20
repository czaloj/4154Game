package;

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
    public static function spawn(gameplayController:GameplayController, state: GameState, renderer:Renderer, gameTime:GameTime) {
        if (gameTime.frame % 120 == 0) {
            for (spawner in state.spawners) {
                var enemy = new ObjectModel();
                enemy.position.set(spawner.position.x, spawner.position.y);
                state.entities.push(enemy);
                gameplayController.createEnemy(gameplayController.physicsController.world, enemy);
                renderer.onEntityAdded(enemy);
            }
        }
     }
    //public static function spawn(gameTime:GameTime, state: GameState) {
        //// TODO: Use variable "level" time
//
        //// TODO: More advanced spawning logic
        //if (gameTime.frame % 120 == 0) {
            //for (spawner in state.spawners) {
                //// TODO: Send a spawn event instead of updating the state in here
            //}
        //}
    //}
}
