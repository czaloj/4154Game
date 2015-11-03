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
import openfl.display.Sprite;
import openfl.geom.Point;
import weapon.Weapon;

class GameplayController {
    public static var GROUND_FRICTION:Float = .3;
    public static var AIR_FRICTION:Float = .95;
    public static inline var TILE_HALF_WIDTH:Float = 0.5;

    public var state:game.GameState;
    public var physicsController:PhysicsController = new PhysicsController();
    private var debugPhysicsView:Sprite;
    private var deletingEntities:Array<Entity> = [];
	private var time:GameTime;

    public function new() {
        // Empty
    }

    public function init(s:GameState):Void {
        state = s;
        
        // Initialize physics from loaded GameState
        physicsController.init(state);
        physicsController.initPlatforms(state);
        
        // Give all the players weapons
        for (i in 0...5) {
            if (state.entities[i] != null) {
                physicsController.initEntity(state.entities[i]);
                if (state.characterWeapons[i] != null) {
                    state.entities[i].weapon = new Weapon(state.entities[i], state.characterWeapons[i]);
                }
            }
        }
        
        // We begin with the first player
        state.player = state.entities[0];
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
                default:
                    // No match found here
            }
        }
        
        state.contactList.clear();
    }
    private function handleEntityPlatform(c:PhysicsContact, e:Entity) {
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

    public function update(s:GameState, gameTime:GameTime):Void {
        state = s;
        time = gameTime;
        // TODO: Spawner shouldn't need reference to this
        Spawner.spawn(this, state, gameTime);
        
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
            projectile.update(time.elapsed, state);
        }
        for (entity in state.entitiesEnabled) {
            if (entity.weapon != null) {
                entity.weapon.update(entity.useWeapon, time.elapsed, s);                
            }
        }
        
        // Physics
        updatePhysics(gameTime);
        
        // Interactions
        handleCollisions();
        for (damage in state.damage) {
            switch (damage.type) {
                case DamageDealer.TYPE_BULLET:
                    var damageBullet:DamageBullet = cast(damage, DamageBullet);
                    if (applyDamageBullet(state, damageBullet, time.elapsed)) {
                        state.projectiles.remove(damageBullet.projectile);
                    }
                case DamageDealer.TYPE_COLLISION_POLYGON:
                    applyDamagePolygon(state, cast(damage, DamagePolygon));
                case DamageDealer.TYPE_RADIAL_EXPLOSION:
                    applyDamageExplosion(state, cast(damage, DamageExplosion));
            }
        }
        state.damage = [];
        
        // Other game logic
        state.projectiles = state.projectiles.filter(function(p:Projectile){
            return 
                p.position.x >= 0 && p.position.x <= state.width * TILE_HALF_WIDTH &&
                p.position.y >= 0 && p.position.y <= state.height * TILE_HALF_WIDTH;
        });
        for (entity in state.entitiesNonNull) {
            if (entity.isDead) deletingEntities.push(entity);
        }
        
        // Destroy all dead things
        if (deletingEntities.length > 0) {
            for (entity in deletingEntities) {
                state.onEntityRemoved.invoke(state, entity);

                // TODO: Make this work better
                if (entity.team != Entity.TEAM_PLAYER) {
                    state.entities.remove(entity);
                }
            }
            deletingEntities = [];
        }
        physicsController.clearDeadBodies();
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
            p.position.x += p.velocity.x * dt.elapsed;
            p.position.y += p.velocity.y * dt.elapsed;
            p.damage.velocityX = p.velocity.x;
            p.damage.velocityY = p.velocity.y;
            p.damage.originX = p.position.x;
            p.damage.originY = p.position.y;
        }
    }
    
    // Application of game events
    public function applyEventSpawn(state:GameState, e:GameEventSpawn):Void {
        var enemy:Entity = new Entity();
        Spawner.createEnemy(enemy, e.entity, e.x, e.y);
        physicsController.initEntity(enemy);
        state.entities.push(enemy);
        state.onEntityAdded.invoke(state, enemy);
    }

    public function applyDamageBullet(state:GameState, bullet:DamageBullet, dt:Float):Bool {
        // Apply the raycast
        var info:Pair<Array<RayCastInfo>, RayCastInfo> = physicsController.rayCastCollisions(
            bullet.originX, bullet.originY,
            bullet.velocityX * dt, bullet.velocityY * dt,
            (bullet.teamDestinationFlags & DamageDealer.TEAM_PLAYER) != 0,
            (bullet.teamDestinationFlags & DamageDealer.TEAM_ENEMY) != 0,
            bullet.piercingAmount
            );
        
        if (info.first.length > 0) {
            // TODO: All entities are damaged
            for (rci in info.first) {
                var hitUD:PhysicsUserData = rci.first.getUserData();
                if (hitUD.first == PhysicsUserDataType.ENTITY) {
                    var hitEntity:Entity = cast(hitUD.second, Entity);
                    hitEntity.health -= bullet.damageFor((hitEntity.team == Entity.TEAM_PLAYER) ? DamageDealer.TEAM_PLAYER : DamageDealer.TEAM_ENEMY);
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
    public function applyDamagePolygon(state:GameState, polygon:DamagePolygon):Void {
        // TODO: Work magic
    }
    public function applyDamageExplosion(state:GameState, explosion:DamageExplosion):Void {
        // TODO: Work magic        
    }
}
