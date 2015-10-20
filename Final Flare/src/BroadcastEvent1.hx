package;

class BroadcastEvent1<A0> {
    private var subscribers:Array<A0->Void> = [];
    
    public function new() {
        // Empty
    }
    
    public function add(f:A0->Void):Void {
        subscribers.push(f);
    }
    public function remove(f:A0->Void):Bool {
        return subscribers.remove(f);
    }
    public function invoke(a0:A0):Void {
        for (f in subscribers) f(a0);
    }
}
