package;

import openfl.geom.Point;

class PlayerController {
    public function new(state:GameState) {
        state.player = new ObjectModel();
        state.player.id = "player";
        state.player.position.setTo(0, 0);
        state.player.grounded = false;
        state.player.rotation = 0;
        state.player.velocity.setTo(0, 0);
        state.player.left = false;
        state.player.right = false;
    }

    public function update(state:GameState, gameTime:GameTime):Void {
        // Move the player on conditional speed
        var moveSpeed = state.player.grounded ? .55 : .35;
        if (state.player.left) state.player.velocity.x -= moveSpeed;
        if (state.player.right) state.player.velocity.x += moveSpeed;
        
        // It seems we want to do conditional friction?
        if (!state.player.left && !state.player.right) {
            var friction = state.player.grounded ? .3 : .9995;
            state.player.velocity.x *= friction;
        }
        
        // Clamp speed to a maximum value
        state.player.velocity.x = Math.min(ObjectModel.MAX_SPEED, Math.max(-ObjectModel.MAX_SPEED, state.player.velocity.x));
    }
}
