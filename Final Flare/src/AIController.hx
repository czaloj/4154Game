package;

class AIController {
    
    public var entities:Array<ObjectModel>;

    public function new() {
    }

    public function move(state:GameState):Void {
        for (entity in state.entities) {
            if (entity.id != "player") {

            }
        }
    }
}
