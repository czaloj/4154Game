package game.damage;

class DamagePolygon extends DamageDealer {
    public var x:Float;
    public var y:Float;
    public var width:Float;
    public var height:Float;
    public function new() {
        super(DamageDealer.TYPE_COLLISION_POLYGON);
    }
}
