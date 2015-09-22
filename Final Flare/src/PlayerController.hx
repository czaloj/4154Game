package;

/**
 * ...
 * @author Mark
 */
//{ Import Statements


//}


class PlayerController extends GameplayController
{
    //{ Fields
    var player:ObjectModel;
    //}


    //{ Initialization
    public function new()
    {
        super();
        player = new ObjectModel();
        player.setID("player");
        player.setPosition(new Point(100, 100);
        player.setGrounded(false);
        player.setRotation(0);
        player.setVelocity(0);

    }
    //}


    //{ Game Loop

    public function update(gameTime:GameTime):Void
    {

    }









	//}


}