package weapon;

import game.EntityBase;
import game.GameState;
import game.Entity;
import game.LargeProjectile;
import game.PhysicsController;
import game.Projectile;
import openfl.geom.Matrix;
import openfl.geom.Point;
import openfl.geom.Transform;
import starling.display.Sprite;
import weapon.WeaponData.FiringMode;
import weapon.WeaponData.ProjectileOrigin;

class Weapon {
    public static var phys:PhysicsController; // TODO: Remove ASAP
    
    public var entity:Entity;
    public var data:WeaponData;
    
    // Firing state
    private var reloadTimeLeft:Float = 0;
    private var shotCooldown:Float = 0;
    private var burstCooldown:Float = 0;
    private var usesPerformed:Int = 0;
    private var burstsLeft:Int = 0;
    
    public function new(e:Entity, d:WeaponData) {
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
        var gunOrigin:Matrix = new Matrix();
        gunOrigin.rotate(entity.weaponAngle);
        gunOrigin.translate( 
            entity.position.x + entity.weaponOffset.x * entity.lookingDirection,
            entity.position.y + entity.weaponOffset.y
            );
        
        var pOrigin:Point = new Point();
        var pDirection:Point = new Point(1, 0);
        
        for (po in data.projectileOrigins) {
            // Obtain a random firing angle
            var a:Float = Math.acos((Math.random() - 0.5) * 2) / Math.PI - 0.5;
            a = a * a * a * po.exitAngle;
            
            // Create the projectile's transformation matrix
            var t:Matrix = new Matrix();
            t.rotate(a);
            t.concat(po.transform);
            t.concat(gunOrigin);
            
            var position:Point = t.transformPoint(pOrigin);
            var direction:Point = t.deltaTransformPoint(pDirection);
            
            if (po.projectile != null) {
                var p:Projectile = po.projectile.createCopyAt(
                    entity,
                    position.x,
                    position.y,
                    direction.x * po.velocity,
                    direction.y * po.velocity
                    );
                s.projectiles.push(p);
                
                // Add a bit of damage if it's been out of the barrel
                if (timeOut > 0) {
                    p.update(timeOut, s);
                    p.position.x += p.velocity.x * timeOut;
                    p.position.y += p.velocity.y * timeOut;
                }
            }
            else if (po.largeProjectile != null) {
                var p:LargeProjectile = po.largeProjectile.createCopyAt(
                    entity,
                    position.x,
                    position.y,
                    direction.x * po.velocity,
                    direction.y * po.velocity,
                    phys
                    );
                
            }
        }
    }
}
