package game.events;
import game.Entity;

class GameEventFlare extends GameEvent {
    // Spawning location
    public var x:Float;
    public var y:Float;
    
    public function new(x:Float, y:Float) {
        super(GameEvent.TYPE_FLARE);
        this.x = x;
        this.y = y;
    }
}
