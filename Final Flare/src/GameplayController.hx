package;

class GameplayController {
	
    private var playerController:PlayerController;
	private var physicsController:PhysicsController;
	

    public function new(state:GameState) {
        init(state);
    }
	
	public function init(state:GameState):Void 
	{
		physicsController = new PhysicsController();
		playerController = new PlayerController(state.player, physicsController.world);
	}

    public function update(state:GameState, gameTime:GameTime):Void {
        playerController.update(state.player, gameTime);
    }
}
