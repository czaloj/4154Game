package;

class Tuple3<A, B, C> {
    public var first:A;
    public var second:B;
    public var third:C;
    
    public function new(o1:A = null, o2:B = null, o3:C = null) {
        first = o1;
        second = o2;
        third = o3;
    }
}
