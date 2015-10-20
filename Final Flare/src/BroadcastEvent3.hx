package;

class BroadcastEvent3<A0, A1, A2> {
    private var subscribers:Array<A0->A1->A2->Void> = [];
    
    public function new() {
        // Empty
    }
    
    public function add(f:A0->A1->A2->Void):Void {
        subscribers.push(f);
    }
    public function remove(f:A0->A1->A2->Void):Bool {
        return subscribers.remove(f);
    }
    public function invoke(a0:A0, a1:A1, a2:A2):Void {
        for (f in subscribers) f(a0, a1, a2);
    }
}
