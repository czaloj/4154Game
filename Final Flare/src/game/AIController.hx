package game;
import game.GameState;

class AIController {
    
    public var entities:Array<game.ObjectModel>;

    public function new() {
    }

    public function addEntity(e:game.ObjectModel):Void {
        entities.push(e);
    }

    public function move(state:game.GameState):Void {
        for (entity in state.entities) {
            if (entity.id != "player") {
                followPlayer(entity, state);
                // entity.up = true; entity.leftFootGrounded = true; entity.velocity.y = 9.5;
                // var target = state.player.position;
                // var x:Float = entity.position.x;
                // var dir = (x-target.x)/Math.abs(x-target.x);    // -1 for left, 1 for right
                // var onLeft = dir > 0;
                // entity.left = onLeft;
                //entity.right = !onLeft;
            }
        }
    }

    // TODO: weee magic numberss
    public function followPlayer(entity:game.ObjectModel, state:game.GameState):Void {
        if (entity.click ) { 
            entity.click = false; 
            entity.countSinceClick = 60; 
            
        }
        if (!entity.click ) {
            entity.countSinceClick--;    
        }
        var target = state.player.position;
        var x:Float = entity.position.x;
        var y:Float = entity.position.y;
        var dir = (x-target.x)/Math.abs(x-target.x);    // -1 for left, 1 for right
        var onLeft = dir > 0;
        
        if (state.player.position.x - x <= 2 && entity.countSinceClick <= 0) {
                entity.click = true;
        }
        entity.up = false; entity.velocity.y = 0; entity.leftFootGrounded = true;
        // if (entity.grounded) {
            if (y > target.y) {
                   entity.left = onLeft;
                   entity.right = !onLeft;
            } else if (y < target.y) {
                   var displacement = x - findPlatformAbove(state,Std.int(x),Std.int(y));
                   if (displacement == 0) {
                       entity.left = onLeft;
                       entity.right = !onLeft;
                   } else if (displacement > 5) {
                       entity.left = true;
                       entity.right = !entity.left;
                   } else if (displacement < -5) {
                       entity.right = true;
                       entity.left = !entity.right;
                   } else {
                       entity.up = true; entity.velocity.y = 9.5;
                   }
               } else {
                   if (state.foreground[Std.int(y*state.width + x + dir)] > 0) {
                       entity.left = onLeft;
                       entity.right = !onLeft;
                   } else {
                      entity.up = true; entity.velocity.y = 9.5;
                   }
               }
        // } else {
               // entity.up = true;
               // entity.left = false;
               // entity.right = false;
        // }
    }

    public function findPlatformLateral(state:game.GameState, curX:Int, curY:Int, dir:Int) {
    }

    public function findPlatformAbove(state:game.GameState, curx:Int, cury:Int) {
        var lastY = cury;
        var lowestY = -1;
        var closestX = -1;
        var closestD:Float = state.width;
        for (i in (cury-1)*state.width...0) {
            var x:Int = (i % state.width);
            var y:Int = (state.height - (Std.int(i / state.width) + 1));
            if (lowestY > 0 && y != lastY) {
                return closestX;
            }
            if (i > 0) {
                lowestY = y;
                var d = Math.abs(curx-x);
                if (d < closestD) {
                    closestX = x;
                    closestD = d;
                }
            }
            lastY = y;
        }
        return Std.int(state.player.position.x);
    }
}
