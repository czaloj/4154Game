package weapon;

import game.GameState;
import game.ObjectModel;
import starling.display.Sprite;

class Weapon extends Sprite {
    public function new(data:WeaponData) {
        super();
    }
    
    public function update(triggerPressed:Bool, dt:Float):Void {
        // TODO: Logic
    }
    
    private function updateAutomatic(triggerPressed:Bool, dt:Float):Void {
        
    }
    private function fireBullets(e:ObjectModel, s:GameState):Void {
        
    }
}
