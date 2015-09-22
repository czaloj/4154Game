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

    private var playerController:PlayerController;

    //}




    //{ Initialization
    public function new()
    {
        super();

    }
    //}



    //{ Game Loop

    public function update(gameTime:GameTime):Void
    {
        throw "abstract";
    }

    //}


}