package;

import graphics.Renderer;
import openfl.display.Graphics;
import openfl.geom.Point;

class Spawner {
    public var id:String;          //Identifying tag

    //Physics data
    public var position:Point = new Point();     //Spawner position

    public function new() {
    }

    public static function spawn(gameplayController:GameplayController, state: GameState, renderer:Renderer) {
        for (spawner in state.spawners) {
            var enemy = new ObjectModel();
            enemy.position.set(spawner.position.x, spawner.position.y);
            state.entities.push(enemy);
            gameplayController.createEnemy(enemy);
            renderer.onEntityAdded(enemy);
        }
    }
}
