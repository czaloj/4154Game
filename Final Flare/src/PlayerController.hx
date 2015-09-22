package;
import openfl.geom.Point;

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
        player.MAX_SPEED = 8;
        player = new ObjectModel();
        player.setID("player");
        player.setPosition(new Point(100, 100);
        player.setGrounded(false);
        player.setRotation(0);
        player.setVelocity(0);
        player.left = false;
        player.right = false;
        player.canJump = false;
        player.canShoot = false;
    }
    //}


    //{ Game Loop

    public function update(gameTime:GameTime):Void
    {
        if (player.canJump)
        {
            player.setVelocity(new Point(player.getPosition().x, -4));
        }

        if (player.IsGrounded)
        {
            if (player.left)
            {
                player.setVelocity(new Point(Math.min(Player.MAX_SPEED, (player.getVelocity()).x + .55f), player.getVelocity().y));
            }
            else if (player.right)
            {
                player.setVelocity(new Point(Math.max( -Player.MAX_SPEED, (player.getVelocity()).x - .55f), player.getVelocity().y);
            }
            else
            {
              player.setVelocity(new Point(player.getVelocity().x * .3f, player.getVelocity().y));
            }
        }
        //Mid-air movement
        else
        {
            if (player.left)
            {
                player.setVelocity(new Point(Math.min(Player.MAX_SPEED, (player.getVelocity()).x + .35f), player.getVelocity().y));
            }
            else if (player.right)
            {
                player.setVelocity(new Point(Math.max( -Player.MAX_SPEED, (player.getVelocity()).x - .35f), player.getVelocity().y);
            }
            else
            {
              player.setVelocity(new Point(player.getVelocity().x * .9995f, player.getVelocity().y));
            }
        }


    }









	//}


}