package;

/**
 * ...
 * @author Mark
 */
//{ Import Statements

//}


class GameplayController
{
    //{ Fields

    public var playerController:PlayerController;

    //}


    //{ Initialization
    public function new(state:GameState)
    {
        playerController = new PlayerController(state);
    }
    //}



    //{ Game Loop

    public function update(state:GameState, gameTime:GameTime):Void
    {
        playerController.update(state, gameTime);
    }

    //}


}