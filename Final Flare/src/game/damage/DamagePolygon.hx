package game.damage;

class DamagePolygon extends DamageDealer {
    public function new() {
        super(DamageDealer.TYPE_COLLISION_POLYGON);
    }
}
