package weapon;

import game.Entity;
import game.GameState;
import game.ObjectModel;
import starling.display.Sprite;
import weapon.WeaponData.FiringMode;

class Weapon {
    public var entity:ObjectModel;
    public var data:WeaponData;
    
    // Firing state
    private var reloadTimeLeft:Float;
    private var shotCooldown:Float;
    private var burstCooldown:Float;
    private var usesPerformed:Int;
    private var burstsLeft:Int;
    
    public function new(e:ObjectModel, d:WeaponData) {
        entity = e;
        data = d;
    }
    
    public function update(triggerPressed:Bool, dt:Float, s:GameState):Void {
        if (reloadTimeLeft > 0) {
            if (reloadTimeLeft > dt) { 
                // We can only continue reloading
                reloadTimeLeft -= dt;
                return;
            }
            else {
                // A full reload is performed
                dt -= reloadTimeLeft;
                reloadTimeLeft = 0;
                
                // Reset gun state for firing
                usesPerformed = 0;
                shotCooldown = 0;
            }
        }
        
        // Update using the trigger
        switch(data.firingMode) {
            case FiringMode.SINGLE:
                updateManual(triggerPressed, dt, s);
            case FiringMode.BURST:
                updateBurst(triggerPressed, dt, s);
            case FiringMode.AUTOMATIC:
                updateAutomatic(triggerPressed, dt, s);
        }
    }
    
    private function updateAutomatic(triggerPressed:Bool, dt:Float, s:GameState):Void {
        if (triggerPressed) {
            while (dt > 0) {
                if (dt < shotCooldown) {
                    // We cannot fire right now
                    shotCooldown -= dt;
                    dt = 0;
                }
                else {
                    // Fire bullets
                    fireBullets(s, dt);
                    usesPerformed += data.usesPerActivation;
                    
                    // Place on cooldown
                    dt -= shotCooldown;
                    shotCooldown = data.activationCooldown;
                    
                    // Check for reload
                    if ((usesPerformed + data.usesPerActivation) > data.useCapacity) {
                        reloadTimeLeft = Math.max(0, data.reloadTime - dt);
                        return;
                    }
                }
            }
        }
        else {
            // Keep updating the cooldown
            shotCooldown = Math.max(0, shotCooldown - dt);
        }
    }
    private function updateManual(triggerPressed:Bool, dt:Float, s:GameState):Void {
        if (triggerPressed) {
             if (dt < shotCooldown) {
                // We cannot fire right now
                shotCooldown -= dt;
            }
            else {
                // Fire bullets
                fireBullets(s, dt - shotCooldown);
                usesPerformed += data.usesPerActivation;
                
                // Place on cooldown
                dt -= shotCooldown;
                shotCooldown = Math.max(0, data.activationCooldown - dt);
                
                // Check for reload
                if ((usesPerformed + data.usesPerActivation) > data.useCapacity) {
                    reloadTimeLeft = Math.max(0, data.reloadTime - dt);
                    return;
                }
            }
        }
        else {
            // Keep updating the cooldown
            shotCooldown = Math.max(0, shotCooldown - dt);
        }
    }
    private function updateBurst(triggerPressed:Bool, dt:Float, s:GameState):Void {
        if (burstsLeft > 0) {
            while (dt > 0 && burstsLeft > 0) {
                if (dt < burstCooldown) {
                    // We cannot fire right now
                    burstCooldown -= dt;
                    dt = 0;
                }
                else {
                    // Fire bullets
                    fireBullets(s, dt);
                    usesPerformed += data.usesPerActivation;
                    
                    // Place on cooldown
                    dt -= burstCooldown;
                    burstCooldown = data.burstPause;
                    
                    // Check for reload
                    if ((usesPerformed + data.usesPerActivation) > data.useCapacity) {
                        reloadTimeLeft = Math.max(0, data.reloadTime - dt);
                        return;
                    }
                }
            }
        }
        else {
            
        }
        
        if (triggerPressed && shotCooldown < dt) {
            // Begin bursting next frame
            shotCooldown = data.activationCooldown;
            burstsLeft = data.burstCount;
        }
        else {
            // Keep updating the cooldown
            shotCooldown = Math.max(0, shotCooldown - dt);
        }
    }
    
    private function fireBullets(s:GameState, timeOut:Float):Void {
        // TODO: Fire all projectiles
    }
}
