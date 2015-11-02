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
import game.PhysicsController.PhysicsUserDataType;
import game.PhysicsController.RayCastInfo;
import openfl.display.Sprite;

class GameplayController {
    public static var PLAYER_MAX_SPEED:Float = 7;
    public static var PLAYER_GROUND_ACCEL:Float = .9;
    public static var PLAYER_AIR_ACCEL:Float = .3;
    public static var PLAYER_GROUND_FRICTION:Float = .3;
    public static var PLAYER_AIR_FRICTION:Float = .95;
    public static inline var TILE_HALF_WIDTH:Float = 0.5;
    public static var BULLET_DAMAGE = 20;
    public static var MELEE_DAMAGE = 20;
    public static var E_DAMAGE = 100;

    public var state:game.GameState;
    public var physicsController:PhysicsController = new PhysicsController();
    private var debugPhysicsView:Sprite;
    private var deletingEntities:Array<Entity> = [];
	private var logger:Logging;
	private var time:GameTime;

    public function new(logg:Logging) {
			logger = logg;// Empty
    }

    public function init(s:GameState):Void {
        state = s;
        
        // Initialize physics from loaded GameState
        physicsController.init(state);
        physicsController.initEntity(state.player);
        physicsController.initPlatforms(state);
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
        for (entity in state.entities) {
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
                    applyDamageBullet(state, cast(damage, DamageBullet));
                case DamageDealer.TYPE_COLLISION_POLYGON:
                    applyDamagePolygon(state, cast(damage, DamagePolygon));
                case DamageDealer.TYPE_RADIAL_EXPLOSION:
                    applyDamageExplosion(state, cast(damage, DamageExplosion));
            }
        }
        
        // Other game logic
        for (entity in state.entities) {
            if (entity.health <= 0) deletingEntities.push(entity);
        }
        
        // Destroy all dead things
        for (entity in deletingEntities) {
            state.onEntityRemoved.invoke(state, entity);
            state.entities.remove(entity);
        }
        physicsController.clearDeadBodies();
    }
    public function updatePhysics(dt:GameTime):Void {
        // Update entity movement input
        for (entity in state.entities) {
            // Add acceleration
            var moveSpeed = entity.isGrounded ? PLAYER_GROUND_ACCEL : PLAYER_AIR_ACCEL;
            if (entity.id == "enemy") {
               moveSpeed /= 2;
            }
            entity.velocity.x += entity.direction * moveSpeed;

            //Apply friction if there is no input command
            if (entity.direction == 0) {
                var friction = entity.isGrounded ? PLAYER_GROUND_FRICTION : PLAYER_AIR_FRICTION;
                entity.velocity.x *= friction;
            }

            // Clamp speed to a maximum value
            entity.velocity.x = Math.min(PLAYER_MAX_SPEED, Math.max(-PLAYER_MAX_SPEED, entity.velocity.x));

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
        for (entity in state.entities) {
            entity.velocity = entity.body.getLinearVelocity().copy();
            entity.position = entity.body.getPosition().copy();
        }

        // Update raycast projectiles
        for (p in state.projectiles) {
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
		logger.recordEvent(2, "" + time.total +", " +e.x + ", " + e.y + ", nullenemid") ;
        physicsController.initEntity(enemy);
        state.entities.push(enemy);
        state.onEntityAdded.invoke(state, enemy);
    }

    public function applyDamageBullet(state:GameState, bullet:DamageBullet):Void {
        // Apply the raycast
        var info:Pair<Array<RayCastInfo>, RayCastInfo> = physicsController.rayCastCollisions(
            bullet.originX, bullet.originY,
            bullet.velocityX, bullet.velocityY,
            (bullet.teamDestinationFlags & DamageDealer.TEAM_PLAYER) != 0,
            (bullet.teamDestinationFlags & DamageDealer.TEAM_ENEMY) != 0,
            bullet.piercingAmount
            );
        
        if (info.first.length > 0) {
            // TODO: All entities are damaged
            for (rci in info.first) {
                var hitEntity:Entity = cast(rci.first.getUserData(), Entity);
                hitEntity.health -= bullet.damageFor(hitEntity.id == "player" ? DamageDealer.TEAM_PLAYER : DamageDealer.TEAM_ENEMY);
				if (hitEntity.health <= 0 && hitEntity.id == "player")
				{
					logger.recordEvent(3, "" + time.total +", " + hitEntity.position.x + ", " + hitEntity.position.y + ", nullcharid, bullet") ;
					logger.recordLevelEnd();
				}
            }
            
            // Apply piercing count
            if (bullet.piercingAmount > 0) {
                bullet.piercingAmount -= info.first.length;
                if (bullet.piercingAmount < 0) {
                    // Bullet has travelled through max enemies
                    // TODO: Bullet is destroyed
                }
            }
        }
        
        // Check for wall hit
        if (info.second != null) {
            // TODO: Bullet is destroyed
        }
    }
    public function applyDamagePolygon(state:GameState, polygon:DamagePolygon):Void {
        // TODO: Work magic
    }
    public function applyDamageExplosion(state:GameState, explosion:DamageExplosion):Void {
        // TODO: Work magic        
    }
}
