package;

class BroadcastEvent {
    private var subscribers:Array<Void->Void> = [];
    
    public function new() {
        // Empty
    }
    
    public function add(f:Void->Void):Void {
        subscribers.push(f);
    }
    public function remove(f:Void->Void):Bool {
        return subscribers.remove(f);
    }
    public function invoke():Void {
        for (f in subscribers) f();
    }
}
