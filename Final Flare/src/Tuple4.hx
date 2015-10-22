package;

class Tuple4<A, B, C, D> {
    public var first:A;
    public var second:B;
    public var third:C;
    public var fourth:D;
    
    public function new(o1:A = null, o2:B = null, o3:C = null, o4:D = null) {
        first = o1;
        second = o2;
        third = o3;
        fourth = o4;
    }
}
