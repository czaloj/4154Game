package game.events;

class GameEventSpawn extends GameEvent {
    public var x:Float;
    public var y:Float;
    public var entity:String;
    
    public function new(x:Float, y:Float, e:String) {
        super(GameEvent.TYPE_SPAWN);
        
        this.x = x;
        this.y = y;
        entity = e;
    }
}
