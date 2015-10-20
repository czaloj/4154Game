package game;

import box2D.common.math.B2Vec2;
import box2D.dynamics.B2Fixture;
import box2D.dynamics.B2World;
import game.events.GameEvent;
import game.events.GameEventSpawn;
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
    private var deletingEntities:Array<ObjectModel> = [];

    public function new() {
        // Empty
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
    
    public function createBullet(world:B2World, entity:ObjectModel, bullet:Projectile):Void {
        bullet.velocity.set(0, 0);
        
        switch(entity.bulletType) {
            case 0:
                bullet.id = "melee";
                bullet.width = 2;
                bullet.height = 2;
            case 1:
                bullet.id = "bullet";
                bullet.width = .05;
                bullet.height = .05;
            case 2:
                bullet.id = "piercingbullet";
                bullet.width = .05;
                bullet.height = .05;
            case 3:
                bullet.id = "explosivebullet";
                bullet.width = .05;
                bullet.height = .05;
            case 4:
                bullet.id = "explosion";
                bullet.width = 4;
                bullet.height = 4;
        }
        
        bullet.position.setV(entity.position);
        bullet.position.x += entity.targetX > bullet.position.x ? 0.6 : -0.6;
        physicsController.initProjectile(bullet, entity, entity.id == "player");
    }

    public function updatePlayerRays(state:GameState):Void {
        //Update left Ray
        state.player.leftRayStart = new B2Vec2(state.player.position.x - (state.player.width/2), state.player.position.y /*- (state.player.height/2)*/);
        state.player.leftRayEnd = new B2Vec2(state.player.leftRayStart.x, state.player.leftRayStart.y - 1);

        //Update right ray
        state.player.rightRayStart = new B2Vec2(state.player.position.x + (state.player.width/2), state.player.position.y /*- (state.player.height/2)*/);
        state.player.rightRayEnd = new B2Vec2(state.player.rightRayStart.x, state.player.rightRayStart.y - 1);

        //Update left wall Ray
        state.player.leftWallRayStart = new B2Vec2(state.player.position.x - (state.player.width/2), state.player.position.y - (state.player.height/2));
        state.player.leftWallRayEnd = new B2Vec2(state.player.leftWallRayStart.x - 1, state.player.leftWallRayStart.y);

        //Update right wall ray
        state.player.rightWallRayStart = new B2Vec2(state.player.position.x - (state.player.width/2), state.player.position.y + (state.player.height/2));
        state.player.rightWallRayEnd = new B2Vec2(state.player.rightWallRayStart.x + 1, state.player.rightWallRayStart.y);
    }
    public function raycastLeftCallback(fixture:B2Fixture, point:B2Vec2, normal:B2Vec2, fraction:Float):Dynamic {
        if (fixture.getBody().getUserData() != null)
        {
            var o = fixture.getBody().getUserData();
            cast(o, Entity);
            if (o.id == "platform")
            {
                state.player.leftFootGrounded= true;
                return fraction;
            }
            else
            {
                return 0;
            }
        }
        return -1;
    }
    public function raycastRightCallback(fixture:B2Fixture, point:B2Vec2, normal:B2Vec2, fraction:Float):Dynamic {
        if (fixture.getBody().getUserData() != null)
        {
            var o = fixture.getBody().getUserData();
            cast(o, Entity);
            if (o.id == "platform")
            {
                state.player.rightFootGrounded= true;
                return fraction;
            }
            else
            {
                return 0;
            }
        }
        return -1;
    }
    public function raycastLeftWallCallback(fixture:B2Fixture, point:B2Vec2, normal:B2Vec2, fraction:Float):Dynamic {
        if (fixture.getBody().getUserData() != null)
        {
            var o = fixture.getBody().getUserData();
            cast(o, Entity);
            if (o.id == "platform")
            {
                state.player.leftTouchingWall= true;
                return fraction;
            }
            else
            {
                return 0;
            }
        }
        return -1;
    }
    public function raycastRightWallCallback(fixture:B2Fixture, point:B2Vec2, normal:B2Vec2, fraction:Float):Dynamic {
        if (fixture.getBody().getUserData() != null)
        {
            var o = fixture.getBody().getUserData();
            cast(o, Entity);
            if (o.id == "platform")
            {
                state.player.rightTouchingWall= true;
                return fraction;
            }
            else
            {
                return 0;
            }
        }
        return -1;
    }
    public function Raycast(world:B2World, o:ObjectModel):Void {

        o.leftFootGrounded = false;
        o.rightFootGrounded = false;
        o.leftTouchingWall  = false;
        o.rightTouchingWall =  false;
        world.rayCast(raycastLeftCallback, o.leftRayStart, o.leftRayEnd);
        world.rayCast(raycastRightCallback, o.rightRayStart, o.rightRayEnd);
        world.rayCast(raycastLeftWallCallback, o.leftWallRayStart, o.leftWallRayEnd);
        world.rayCast(raycastRightWallCallback, o.rightWallRayStart, o.rightWallRayEnd);
    }

    public function handleCollisions():Void {
        for (contact in state.contactList) {
            // Check what was in collision
            if (contact != null) {
                var entity1 = cast(contact.getFixtureA().getBody().getUserData(), Entity);
                var entity2 = cast(contact.getFixtureB().getBody().getUserData(), Entity);
                var id1 = entity1.id;
                var id2 = entity2.id;
                
                if (id1 == "bullet" || id1 == "melee" || id1 == "explosivebullet" || id1 =="explosion") {
                    state.onProjectileRemoved.invoke(state, cast(entity1, Projectile));
                }
                if (id2 == "bullet" || id2=="melee" || id2 =="explosivebullet" || id2=="explosion") {
                    state.onProjectileRemoved.invoke(state, cast(entity2, Projectile));
                }
                
                //When a player is hit by normal bullet
                if (( id1 == "enemy") && (id2 == "bullet"||id2=="piercingbullet")) {
                    var entity1o = cast(entity1, ObjectModel);
                    entity1o.health -= BULLET_DAMAGE;
                    if (entity1o.health <= 0) {
                        deletingEntities.push(entity1o);
                    }
                }
                
                if ((id2 == "enemy") && (id1 == "bullet"||id1 =="piercingbullet")) {
                    //player takes damage;
                    //mark bullet for destreuction
                    var entity2o = cast(entity2, ObjectModel);
                    entity2o.health -= BULLET_DAMAGE;
                    if (entity2o.health <= 0) {
                        deletingEntities.push(entity2o);
                    }
                }
                if (( id1 == "enemy") && id2 == "explosivebullet") {
                    var entity1o = cast(entity1, ObjectModel);
                    entity1o.bulletType = 4;
                    var explosion:Projectile = new Projectile();
                    createBullet(physicsController.world, entity1o, explosion);
                    explosion.targetX = entity1o.targetX;
                    explosion.targetY = entity1o.targetY;
                }
                
                if (( id2 == "enemy") && id1 == "explosivebullet") {
                    var entity2o = cast(entity2, ObjectModel);
                    entity2o.bulletType = 4;
                    var explosion:Projectile = new Projectile();
                    createBullet(physicsController.world, entity2o, explosion);
                    explosion.targetX = entity2o.targetX;
                    explosion.targetY = entity2o.targetY;
                }
                
                if (( id1 == "enemy"||id1=="player") && id2 == "explosion") {
                    var entity1o = cast(entity1, ObjectModel);
                    entity1o.health -= E_DAMAGE;
                    if (entity1o.health <= 0) {
                        deletingEntities.push(entity1o);
                    }
                }
                
                if ((id2 == "enemy"||id2=="player") && id1 == "explosion") {
                    //player takes damage;
                    //mark bullet for destreuction
                    var entity2o = cast(entity2, ObjectModel);
                    entity2o.health -= E_DAMAGE;
                    if (entity2o.health <= 0) {
                        deletingEntities.push(entity2o);
                    }

                }
                if ((id1 == "player" ) && id2 == "melee") {
                    var entity1o = cast(entity1, ObjectModel);
                    entity1o.health -=  MELEE_DAMAGE;
                    if (entity1o.health <= 0) {
                        deletingEntities.push(entity1o);
                    }
                }
                
                if ((id2 == "player" ) && id1 == "melee") {
                    //player takes damage;
                    //mark bullet for destreuction
                    var entity2o = cast(entity2, ObjectModel);
                    entity2o.health -=  MELEE_DAMAGE;
                    if (entity2o.health <= 0) {
                        deletingEntities.push(entity2o);
                    }
                }
            }

            // TODO: Contact list should be a special tuple of <GameObjectType, Dynamic> to get correct casting results
        }
        
        state.contactList.clear();
    }

    public function update(s:GameState, gameTime:GameTime):Void {
        state = s;
        
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

        // Update entity movement
        for (entity in state.entities) {
            //UPDATES VELOCITY
            entity.velocity = entity.body.getLinearVelocity().copy();
            
            if (entity.swap2&& entity.canSwap2) {
                entity.canSwap2 = false;
                entity.bulletType = 2;
                entity.health = 150;
            }
            if (entity.swap3 && entity.canSwap3) {
                entity.canSwap3 = false;
                entity.bulletType = 3;
                entity.health = 200;
            }
            //Just in case -__-
            var moveSpeed = entity.grounded ? PLAYER_GROUND_ACCEL : PLAYER_AIR_ACCEL;
            if (entity.id == "enemy") {
               moveSpeed /= 2; 
            }
            if (entity.left) entity.velocity.x -= moveSpeed;
            if (entity.right) entity.velocity.x += moveSpeed;

            //Apply friction if there is no input command
            if (!entity.left && !entity.right) {
                var friction = entity.grounded ? PLAYER_GROUND_FRICTION : PLAYER_AIR_FRICTION;
                entity.velocity.x *= friction;
            }

            // Clamp speed to a maximum value
            entity.velocity.x = Math.min(PLAYER_MAX_SPEED, Math.max(-PLAYER_MAX_SPEED, entity.velocity.x));

            if (entity.up && entity.grounded) {
                entity.velocity.y = 9.5;
            }
            entity.body.setLinearVelocity(entity.velocity.copy()); //So that the velocity actually does something
            //UPDATE POSITION
            entity.position = entity.body.getPosition();


            //TODO This should be its own function
            if (entity.click) {
                var bullet:Projectile = new Projectile();
                createBullet(physicsController.world, entity, bullet);
                bullet.targetX = entity.targetX;
                bullet.targetY = entity.targetY;
                bullet.setVelocity();
                state.bullets.push(bullet);  //push bullet onto gamestate bullets
                state.onProjectileAdded.invoke(state, bullet);
                if (bullet.id == "melee") { bullet.velocity = new B2Vec2(0, 0);}
                bullet.body.setLinearVelocity(bullet.velocity);
            }
        }
        
        // Update physics
        physicsController.update(gameTime.elapsed);
        
        updatePlayerRays(state); //Update Raycast Rays. WILL CHANGE TO ENITITY IF NEEDED
        Raycast(physicsController.world, state.player);
        handleCollisions();
        
        // Destroy all dead things
        for (entity in deletingEntities) {
            state.onEntityRemoved.invoke(state, entity);
            state.entities.remove(entity);
        }
        physicsController.clearDeadBodies();
    }

    // Application of game events
    public function applyEventSpawn(state:GameState, e:GameEventSpawn) {
        var enemy:ObjectModel = new ObjectModel();
        Spawner.createEnemy(enemy, e.entity, e.x, e.y);
        physicsController.initEntity(enemy);
        state.entities.push(enemy);
        state.onEntityAdded.invoke(state, enemy);
    }
}
