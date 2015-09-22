package;

import openfl.geom.Point;

class PlayerController
{
    //{ Initialization
    public function new(state:GameState)
    {
        state.player = new ObjectModel();
        state.player.id = "player";
        state.player.position.setTo(0, 0);
        state.player.grounded = false;
        state.player.rotation = 0;
        state.player.velocity.setTo(0, 0);
        state.player.left = false;
        state.player.right = false;
    }
    //}


    //{ Game Loop

    public function update(state:GameState, gameTime:GameTime):Void
    {
        if (state.player.grounded)
        {
            if (state.player.left)
            {
                state.player.velocity.setTo(Math.min(ObjectModel.MAX_SPEED, (state.player.velocity).x + .55), state.player.velocity.y);
            }
            else if (state.player.right)
            {
                state.player.velocity.setTo(Math.max( -ObjectModel.MAX_SPEED, (state.player.velocity).x - .55), state.player.velocity.y);
            }
            else
            {
              state.player.velocity.setTo(state.player.velocity.x * .3, state.player.velocity.y);
            }
        }
        //Mid-air movement
        else
        {
            if (state.player.left)
            {
                state.player.velocity.setTo(Math.min(ObjectModel.MAX_SPEED, (state.player.velocity).x + .35), state.player.velocity.y);
            }
            else if (state.player.right)
            {
                state.player.velocity.setTo(Math.max( -ObjectModel.MAX_SPEED, (state.player.velocity).x - .35), state.player.velocity.y);
            }
            else
            {
              state.player.velocity.setTo(state.player.velocity.x * .9995, state.player.velocity.y);
            }
        }
    }
//}


}