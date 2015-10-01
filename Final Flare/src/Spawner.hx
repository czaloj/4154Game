package;

import openfl.geom.Point;

class Spawner {
    public var id:String;          //Identifying tag

    //Physics data
    public var position:Point = new Point();     //Spawner position

    public function new() {
    }

    public function spawn(state: GameState) {
        for (spawner in state.spawners) {
            var enemy = new ObjectModel();
            enemy.position.setTo(spawner.position.x, spawner.position.y);
            state.entities.push(enemy);
        }
    }
}
