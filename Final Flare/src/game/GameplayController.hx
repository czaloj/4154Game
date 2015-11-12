package game;

import box2D.common.math.B2Vec2;
import box2D.dynamics.B2Fixture;
import box2D.dynamics.B2World;
import game.damage.DamageBullet;
import game.damage.DamageDealer;
import game.damage.DamageExplosion;
import game.damage.DamagePolygon;
import game.events.GameEvent;
import game.events.GameEventSpawn;
import game.PhysicsController.PhysicsContact;
import game.PhysicsController.PhysicsContactBody;
import game.PhysicsController.PhysicsUserData;
import game.PhysicsController.PhysicsUserDataType;
import game.PhysicsController.RayCastInfo;
import graphics.IGameVisualizer;
import openfl.display.Sprite;
import openfl.geom.Point;
import weapon.projectile.Projectile;
import weapon.Weapon;

class GameplayController {
    public static var COMBO_COOLDOWN:Float = 0.4;
    public static var COMBO_COOLDOWN_DELAY:Float = 2.0;
    public static var GROUND_FRICTION:Float = .3;
    public static var AIR_FRICTION:Float = .95;
    public static inline var TILE_HALF_WIDTH:Float = 0.5;
    public static var INVINCIBILITY_TIME = 2.0;

    public var state:game.GameState;
    public var physicsController:PhysicsController = new PhysicsController();
    private var debugPhysicsView:Sprite;
    private var deletingEntities:Array<Entity> = [];
    private var deletingProjectiles:Array<Projectile> = [];
    var count20:Int;
    
    private var comboCooldownDelay:Float = COMBO_COOLDOWN_DELAY;
    private var flaresReceived:Int = 0;

    private var vis:IGameVisualizer;

    public function new() {
        // Empty
    }

    public function init(s:GameState):Void {
        state = s;
        count20 = 1200;

        // Initialize physics from loaded GameState
        Weapon.phys = physicsController;
        physicsController.init(state);
        physicsController.initPlatforms(state);

        // Give all the players weapons
        for (i in 0...5) {
            if (state.entities[i] != null) {
                physicsController.initEntity(state.entities[i]);
                if (state.characterWeapons[i] != null) {
                    state.entities[i].weapon = new Weapon(state.entities[i], state.characterWeapons[i]);
                }
                state.entities[i].flareGun = new Weapon(state.entities[i], state.characterWeapons[5]);
            }
        }

        // We begin with the first player
        state.player = state.entities[0];
    }
    public function setVisualizer(v:IGameVisualizer):Void {
        vis = v;

        vis.onEntityAdded(state, state.player);
    }

    public function initDebug(debugPhysicsView:Sprite):Void {
        // Create a debug view of the physics world
        debugPhysicsView.x = ScreenController.SCREEN_WIDTH / 2;
        debugPhysicsView.y = ScreenController.SCREEN_HEIGHT / 2;
        debugPhysicsView.scaleY = -debugPhysicsView.scaleY;
        physicsController.initDebug(debugPhysicsView);
    }
    public function drawDebug():Void {
        physicsController.renderDebug();
    }

    public function handleCollisions():Void {
        for (contact in state.contactList) {
            if (contact == null) continue;

            var object1:PhysicsContactBody = contact.object1;
            var object2:PhysicsContactBody = contact.object2;

            // Match collision patterns
            switch [object1.first, object2.first] {
                case [PhysicsUserDataType.ENTITY, PhysicsUserDataType.ENTITY]:
                    // TODO: Logic
                case [PhysicsUserDataType.ENTITY, PhysicsUserDataType.PLATFORM]:
                    contact.collisionNormal.negativeSelf();
                    handleEntityPlatform(contact, cast(object1.second, Entity));
                case [PhysicsUserDataType.PLATFORM, PhysicsUserDataType.ENTITY]:
                    handleEntityPlatform(contact, cast(object2.second, Entity));
                    // TODO: Add collision types
                case [PhysicsUserDataType.ENTITY, PhysicsUserDataType.PROJECTILE]:
                    contact.collisionNormal.negativeSelf();
                    handleEntityProjectile(contact, cast(object1.second, Entity), cast(object2.second, Projectile));
                case [PhysicsUserDataType.PROJECTILE, PhysicsUserDataType.ENTITY]:
                    handleEntityProjectile(contact, cast(object2.second, Entity), cast(object1.second, Projectile));
                case [PhysicsUserDataType.PROJECTILE, PhysicsUserDataType.PLATFORM]:
                    contact.collisionNormal.negativeSelf();
                    handleProjectilePlatform(contact, cast(object1.second, Projectile));
                case [PhysicsUserDataType.PLATFORM, PhysicsUserDataType.PROJECTILE]:
                    handleProjectilePlatform(contact, cast(object2.second, Projectile));
                default:
                    // No match found here
            }
        }

        state.contactList.clear();
    }
    private function handleEntityPlatform(c:PhysicsContact, e:Entity):Void {
        if (c.collisionNormal.y > 0.8) {
            e.feetTouches += c.isBegin ? 1 : -1;
        }
        else if (c.collisionNormal.x > 0.8) {
            e.leftTouchingWall += c.isBegin ? 1 : -1;
        }
        else if (c.collisionNormal.x < -0.8) {
            e.rightTouchingWall += c.isBegin ? 1 : -1;
        }
    }
    private function handleEntityProjectile(c:PhysicsContact, e:Entity, p:Projectile):Void {
        p.fOnHit(state);
    }
    private function handleProjectilePlatform(c:PhysicsContact, p:Projectile):Void {
        p.fOnHit(state);
    }

    public function update(s:GameState, gameTime:GameTime):Void {
        state = s;
        updateTime(gameTime);
        
        // TODO: Super old logging code, excise
        count20 -= 1;
        if (count20 <= 0)
        {
            count20 = 1200;
            var str:String;
            str = "";
            for (ent in s.entitiesNonNull) {
                str += ent.position.x + ", "+ ent.position.y+", ";
            }
            FFLog.recordEvent(8, str + state.time.total);
        }
        // TODO: Spawner shouldn't need reference to this
        Spawner.spawn(this, state, state.time);

        // Update looking directions
        updateTargeting();

        // Update game events
        if (state.gameEvents.length > 0) {
            for (event in state.gameEvents) {
                switch(event.type) {
                    case GameEvent.TYPE_SPAWN:
                        applyEventSpawn(state, cast(event, GameEventSpawn));
                }
            }
            state.gameEvents = [];
        }

        // Create damage dealers
        for (projectile in state.projectiles) {
            projectile.update(state.time.elapsed, state);
        }
        for (entity in state.entitiesEnabled) {
            if (entity.damageTimer > 0) {
                entity.damageTimer -= state.time.elapsed;
            }
            if (entity.weapon != null) {
                entity.weapon.update(entity.useWeapon, state.time.elapsed, s);
            }
            if (entity.flareGun != null) {
                entity.flareGun.update(entity.useFlare, state.time.elapsed, s);
            }
        }
        
        // Physics
        updatePhysics(state.time);
        
        // Interactions
        handleCollisions();
        for (damage in state.damage) {
            switch (damage.type) {
                case DamageDealer.TYPE_BULLET:
                    var damageBullet:DamageBullet = cast(damage, DamageBullet);
                    if (applyDamageBullet(state, damageBullet, state.time.elapsed)) {
                        state.projectiles.remove(damageBullet.projectile);
                    }
                case DamageDealer.TYPE_COLLISION_POLYGON:
                    applyDamagePolygon(state, cast(damage, DamagePolygon), state.time);
                case DamageDealer.TYPE_RADIAL_EXPLOSION:
                    applyDamageExplosion(state, cast(damage, DamageExplosion));
            }
        }
        state.damage = [];

        // Other game logic
        for (entity in state.entitiesNonNull) {
            if (entity.isDead) {
                deletingEntities.push(entity);
                if (entity.id != "player") {
                    state.score++;
                }
            }
        }
        for (p in state.projectiles) {
            if (p.killFlag || (
                p.position.x < 0 || p.position.x > state.width * TILE_HALF_WIDTH ||
                p.position.y < 0 || p.position.y > state.height * TILE_HALF_WIDTH
                )) {
                deletingProjectiles.push(p);
            }
        }
        
        // Destroy all dead things
        if (deletingEntities.length > 0) {
            for (entity in deletingEntities) {
                vis.onEntityRemoved(state, entity);
                physicsController.onEntityRemoved(state, entity);

                // TODO: Make this work better
                if (entity.team != Entity.TEAM_PLAYER) {
                    state.entities.remove(entity);
                }
                
            }
            deletingEntities = [];
        }
        if (deletingProjectiles.length > 0) {
            for (p in deletingProjectiles) {
                p.fOnDeath(state);
                state.projectiles.remove(p);
            }
            deletingProjectiles = [];
        }
        physicsController.clearDeadBodies();
        
        // Update current score for other modules to interface with it
        updateScoring();
    }
    public function updateTime(gameTime:GameTime):Void {
        state.time.elapsed = gameTime.elapsed * state.timeMultiplier;
        state.time.total += state.time.elapsed;
        
        // Frame must always increase by 1, no matter the multiplier
        state.time.frame += 1;
        
        // Update flare information
        state.flareCountdown -= state.time.elapsed;
        if (state.flareCountdown < 0.0) {
            state.flareCountdown = flaresReceived * 30 + 120;
            state.flares += 1;
            flaresReceived += 1;
        }
    }
    public function updateScoring():Void {
        if (comboCooldownDelay < 0) {
            // Combo meter deteriorates just as fast on every level
            state.comboPercentComplete -= state.time.elapsed * COMBO_COOLDOWN;
            if (state.comboPercentComplete < 0) {
                if (state.comboMultiplier > 1) {
                    state.comboPercentComplete = 1.0;
                    state.comboMultiplier -= 1;
                }
                else {
                    // Rock bottom
                    state.comboPercentComplete = 0.0;
                }
            }
        }
        else {
            // Wait until it's time to decrease the combo
            comboCooldownDelay -= state.time.elapsed;
        }
        
        if (state.score == 80085) {
            // TODO: Achievement get...
        }
    }
    public function updateTargeting():Void {
        for (e in state.entitiesEnabled) {
            e.headAngle = Math.atan2(
                e.targetY - (e.position.y + e.headOffset.y),
                e.targetX - (e.position.x + e.headOffset.x * e.lookingDirection)
            );
            e.weaponAngle = Math.atan2(
                e.targetY - (e.position.y + e.weaponOffset.y),
                e.targetX - (e.position.x + e.weaponOffset.x * e.lookingDirection)
            );
        }
    }
    public function updatePhysics(dt:GameTime):Void {
        // Update entity movement input
        for (entity in state.entitiesNonNull) {
            // Add acceleration
            var moveSpeed = entity.isGrounded ? entity.groundAcceleration : entity.airAcceleration;
            entity.velocity.x += entity.direction * moveSpeed;

            //Apply friction if there is no input command
            if (entity.direction == 0) {
                var friction = entity.isGrounded ? GROUND_FRICTION : AIR_FRICTION;
                entity.velocity.x *= friction;
            }

            // Clamp speed to a maximum value
            entity.velocity.x = Math.min(entity.maxMoveSpeed, Math.max(-entity.maxMoveSpeed, entity.velocity.x));

            // Jump up
            if (entity.up && entity.isGrounded) {
                entity.velocity.y = 9.5;
            }

            // Update the body
            entity.body.setLinearVelocity(entity.velocity.copy());
            entity.body.setPosition(entity.position.copy());
        }

        // Simulate the world
        physicsController.update(dt.elapsed);

        // Reapply from physics
        for (entity in state.entitiesNonNull) {
            entity.velocity = entity.body.getLinearVelocity().copy();
            entity.position = entity.body.getPosition().copy();
        }

        // Update raycast projectiles
        for (p in state.projectiles) {
            p.updatePostPhysics(dt.elapsed, state);
        }
    }

    // Application of game events
    public function applyEventSpawn(state:GameState, e:GameEventSpawn):Void {
        var enemy:Entity = new Entity();
        Spawner.createEnemy(enemy, e.entity, e.x, e.y);
        physicsController.initEntity(enemy);
        state.entities.push(enemy);
        vis.onEntityAdded(state, enemy);
        FFLog.recordEvent(2, enemy.position.x + ", " + enemy.position.y + ", " + state.time.total);
    }

    // Damage events
    public function applyDamageBullet(state:GameState, bullet:DamageBullet, dt:Float):Bool {
        // Apply the raycast
        var info:Pair<Array<RayCastInfo>, RayCastInfo> = physicsController.rayCastCollisions(
            bullet.originX, bullet.originY,
            bullet.velocityX * dt, bullet.velocityY * dt,
            (bullet.teamDestinationFlags & DamageDealer.TEAM_PLAYER) != 0,
            (bullet.teamDestinationFlags & DamageDealer.TEAM_ENEMY) != 0,
            bullet.piercingAmount
            );
        vis.addBulletTrail(bullet.originX, bullet.originY, bullet.originX + bullet.velocityX * dt, bullet.originY + bullet.velocityY * dt, 0.2);

        if (info.first.length > 0) {
            // TODO: All entities are damaged
            for (rci in info.first) {
                var hitUD:PhysicsUserData = rci.first.getUserData();
                if (hitUD.first == PhysicsUserDataType.ENTITY) {
                    if (attemptDamage(cast(hitUD.second, Entity), bullet)) {
                        vis.onBloodSpurt(rci.third.x, rci.third.y, rci.fourth.x, rci.fourth.y);
                    }
                }
            }
            
            // Apply piercing count
            if (bullet.piercingAmount > 0) {
                bullet.piercingAmount -= info.first.length;
                if (bullet.piercingAmount < 0) {
                    // Bullet has travelled through max enemies
                    return true;
                }
            }
            else {
                // Non-piercing bullet hit something
                return true;
            }
        }

        // Check for wall hit
        return info.second != null;
    }
    public function applyDamagePolygon(state:GameState, polygon:DamagePolygon, time:GameTime):Void {
        // TODO: Use Query instead of multiple entity tests
    }
    public function applyDamageExplosion(state:GameState, explosion:DamageExplosion):Void {
        var hits:Array<PhysicsUserData> = physicsController.hitTest(explosion.x, explosion.y, explosion.radius, true, true);
        for (hit in hits) {
            attemptDamage(cast(hit.second, Entity), explosion);
        }
    }
    
    private function attemptDamage(e:Entity, d:DamageDealer):Bool {
        if (e.enabled && e.canBeDamaged) {
            var damage:Int = d.damageFor((e.team == Entity.TEAM_PLAYER) ? DamageDealer.TEAM_PLAYER : DamageDealer.TEAM_ENEMY);
            e.health -= damage;
            e.damageTimer = INVINCIBILITY_TIME;
            // TODO: Record damage?
            
            // TODO: Causes of death
            if (e.isDead && e.team == Entity.TEAM_ENEMY) {
                FFLog.recordEvent(1,  e.position.x + ", " + e.position.y + ", " + state.time.total);
            }
            if (e.isDead && e.team == Entity.TEAM_PLAYER) {
                FFLog.recordEvent(3,  e.position.x + ", " + e.position.y + ", " + state.time.total); 
            }
            
            return damage > 0;
        }
        return false;
    }
}
