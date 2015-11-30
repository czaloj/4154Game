package game;

import game.GameState;
import game.Region;

class AIController {
    public static inline var VIEW_LOOKAHEAD:Float = 1000.0;
    public static inline var VIEW_LOOK_TIME:Float = 2.0;

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
        entity.targetX = state.player.position.x;
        entity.targetY = state.player.position.y;
		if (y ==target.y)//< target.y+.05 && y > target.y-.05)
		{
			entity.controlDefault = true;
		}
		if(entity.controlDefault){ //simply looks for player. hopefully this is only true if player is on same level or a level that can be fallen to from current one
			entity.direction = x > target.x ? -1 : 1;
		}
		entity.count++;
					if (entity.count % 17 == 0) {
						if (x == entity.prevX) {
							entity.controlDefault = false;
							entity.direction *= -1;
						}
						entity.prevX = x;
					}

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
			if(y < entity.yProblem -.05) { //return controls to default
					entity.controlDefault = true;
				}
            if (y>target.y+.05) {
				if (x < target.x+.1 && x > target.x -.1 && entity.get_isGrounded()) {
					entity.yProblem = y;
					entity.prevX = x;
					entity.count = 1;
					entity.direction = x<20? 1:-1;
					entity.controlDefault = false;
				}

				/*if(!(y < entity.yProblem -.05)) {
					entity.count++;
					if (entity.count % 17 == 0) {
						if (x == entity.prevX) {
							controlDefault = false;
							entity.direction *= -1;
						}
						entity.prevX = x;
					}


				}*/

            }
            if (y < target.y-.05) {

                var displacement = x - findPlatformAbove(state, Std.int(x), Std.int(y));
				if(x < target.x+.05 && x > target.x -.05 ){
					entity.direction = displacement < 0 ? -1:1;
					entity.controlDefault = false;

				}
				entity.count++;
				if (entity.count % 17 == 0) {
					if (x==entity.prevX) {
							entity.direction *= -1;
						}
						entity.prevX = x;
					}
                if (displacement == 0) {
					entity.controlDefault = false;
                }
                else if (displacement > 5) {

					return;
                }
                else if (displacement < -5) {
					//entity.direction = -1;
					return;
                }
                else {
                    entity.up = true;
                }
            } else {
                if (state.foreground[Std.int(y*state.width + x + entity.direction)] > 0) { //confused what this even does
                }
                else {
                   // entity.up = true;
                }
            }

        //else {
            //entity.up = true;
        }


    public function findPlatformLateral(state:GameState, curX:Int, curY:Int, dir:Int):Int {
        return 0; // ?
    }

    public function findPlatformAbove(state:GameState, curx:Int, cury:Int):Int { //what does this return
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

     public function findPlayer(entity:Entity, state:GameState){
        var target = state.player.position;
        var x:Float = entity.position.x;
        var y:Float = entity.position.y;
        var region:Region = state.regionLists.get(toRegion(x, y, state));
        var playerRegion: Region = state.regionLists.get(toRegion(target.x, target.y, state));
        return region.getDirection(playerRegion);
     }

     public function toRegion(x:Float, y:Float, state:GameState) {
         var tx = Math.floor(x / GameplayController.TILE_HALF_WIDTH);
         var ty = Math.floor(y / GameplayController.TILE_HALF_WIDTH);
         return state.regions[tx + ty * state.width];
     }
}
