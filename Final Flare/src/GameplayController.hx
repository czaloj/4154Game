package;

/**
 * ...
 * @author Mark
 */
//{ Import Statements

//}


class GameplayController extends GameScreen
{
    //{ Fields

    public var playerController:PlayerController;

    //}


    //{ Initialization
    public function new()
    {
        playerController = new PlayerController();

    }
    //}



    //{ Game Loop

    public function update(gameTime:GameTime):Void
    {
        playerController.update(gameTime);
    }

    //}


}