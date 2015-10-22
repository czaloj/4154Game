package game.damage;

class DamageExplosion extends DamageDealer {
    public function new() {
        super(DamageDealer.TYPE_RADIAL_EXPLOSION);
    }
}
