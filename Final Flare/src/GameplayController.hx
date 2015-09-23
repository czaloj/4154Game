package;

class GameplayController {
    private var playerController:PlayerController;

    public function new(state:GameState) {
        playerController = new PlayerController(state);
    }

    public function update(state:GameState, gameTime:GameTime):Void {
        playerController.update(state, gameTime);
    }
}
