package game;

import game.GameState;

class AIController {
    public function new() {
        // Empty
    }

    public function move(state:GameState):Void {
        for (entity in state.entitiesNonNull) {
            if (entity.team == Entity.TEAM_ENEMY) {
                followPlayer(entity, state);
            }
        }
    }

    // TODO: weee magic numberss
    public function followPlayer(entity:Entity, state:GameState):Void {
        var target = state.player.position;
        var x:Float = entity.position.x;
        var y:Float = entity.position.y;
        var dir = (x - target.x) / Math.abs(x - target.x);    // -1 for left, 1 for right
        var onLeft = dir > 0;
        
        if (Math.abs(state.player.position.x - x) <= 2) {
            entity.useWeapon = true;
        }
        else {
            entity.useWeapon = false;
        }
        entity.up = false;
        if (entity.isGrounded) {
            if (y > target.y) {
            } 
            else if (y < target.y) {
                var displacement = x - findPlatformAbove(state,Std.int(x),Std.int(y));
                if (displacement == 0) {
                } 
                else if (displacement > 5) {
                }
                else if (displacement < -5) {
                } 
                else {
                    entity.up = true;
                }
            } else {
                if (state.foreground[Std.int(y*state.width + x + dir)] > 0) {
                }
                else {
                    entity.up = true;
                }
            }
        }
        else {
            entity.up = true;
        }
    }

    public function findPlatformLateral(state:GameState, curX:Int, curY:Int, dir:Int):Int {
        return 0; // ?
    }

    public function findPlatformAbove(state:GameState, curx:Int, cury:Int):Int {
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
