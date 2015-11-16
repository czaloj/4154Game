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
		//var controlDefault:Bool = true;
		if(entity.controlDefault){
			entity.direction = x > target.x ? -1 : 1;
		}
		
		//entity.yProblem = 1000;
		var prevX:Float = x;
        var count:Int = 1;
		
        if (Math.abs(state.player.position.x - x) <= 2) {
            entity.useWeapon = true;
        }
        else {
            entity.useWeapon = false;
        }
        entity.up = false;
        //if (entity.isGrounded) {
			if(y < entity.yProblem -.05) {
					entity.controlDefault = true;
				}
            if (y>target.y+.05) {
				if (x < target.x+.05 && x > target.x -.05) {
					entity.yProblem = y;
					prevX = x;
					count = 1;
					entity.direction = x<10? 1:-1;
					entity.controlDefault = false;
				}
				
				if(!(y < entity.yProblem -.05)) {
					count++;
					if (count % 7 == 0) {
						if (prevX == x) {
							entity.direction *= -1;	
						}
						prevX = x;
					}
					
					
				}
				
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
                if (state.foreground[Std.int(y*state.width + x + entity.direction)] > 0) {
                }
                else {
                    entity.up = true;
                }
            }
        
        //else {
            //entity.up = true;
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
