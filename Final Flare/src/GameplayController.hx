package;

import box2D.dynamics.contacts.B2Contact;
import openfl.display.Sprite;
import openfl.geom.Point;
import box2D.dynamics.B2Body;
import box2D.dynamics.B2BodyDef;
import box2D.dynamics.B2Fixture;
import box2D.dynamics.B2FixtureDef;
import box2D.collision.shapes.B2PolygonShape;
import box2D.common.math.B2Vec2;
import box2D.dynamics.B2DebugDraw;
import box2D.common.B2Color;
import box2D.dynamics.B2World;
import box2D.dynamics.B2ContactFilter;
import openfl.Lib;

class GameplayController {
    public static var PLAYER_MAX_SPEED:Float = 9;
    public static var PLAYER_GROUND_ACCEL:Float = 4;
    public static var PLAYER_AIR_ACCEL:Float = 3;
    public static var PLAYER_GROUND_FRICTION:Float = .8;
    public static var PLAYER_AIR_FRICTION:Float = .95;
    public static inline var TILE_HALF_WIDTH:Float = 0.5;

    public var state:GameState;
    public var physicsController:PhysicsController;
    private var debugPhysicsView:Sprite;

    public function new() {
        // Empty
    }

    public function initDebug(debugPhysicsView:Sprite):Void {
        // Create a debug view of the physics world
        debugPhysicsView.x = ScreenController.SCREEN_WIDTH / 2;
        debugPhysicsView.y = ScreenController.SCREEN_HEIGHT / 2;
        debugPhysicsView.scaleY = -debugPhysicsView.scaleY;
        physicsController.initDebug(debugPhysicsView);
    }

    public function init(s:GameState):Void {
        state = s;
        physicsController = new PhysicsController(state);
        createPlayer(physicsController.world, state.player);
        state.entities.push(state.player);
        for (i in 0...(state.width * state.height)) {
            var x:Float = (i % state.width) * TILE_HALF_WIDTH + (TILE_HALF_WIDTH * 0.5);
            var y:Float = (state.height -  (Std.int(i / state.width) + 1)) * TILE_HALF_WIDTH + (TILE_HALF_WIDTH * 0.5);
            if (state.foreground[i] != 0) {
                // TODO: Platforms are not ObjectModels
                var platform = new ObjectModel();
                createPlatform(physicsController.world, platform, x, y);
            }
         }
    }

    public function createPlatform(world:B2World, platform:ObjectModel, x:Float, y:Float):Void {
        // TODO: Platforms are not ObjectModels
        var platform = new ObjectModel();
        platform.id = "platform";
        platform.position.set(x, y);
        platform.grounded = false;
        platform.rotation = 0;
        platform.velocity.set(0,0);
        platform.left = false;
        platform.right = false;
        platform.height = TILE_HALF_WIDTH;
        platform.width = TILE_HALF_WIDTH;

        platform.bodyDef = new B2BodyDef();
        platform.bodyDef.position.set(platform.position.x, platform.position.y);
        platform.bodyDef.type = B2Body.b2_staticBody;

        var polygon = new B2PolygonShape ();
        polygon.setAsBox ((platform.width)/2, (platform.height)/2);

        platform.fixtureDef = new B2FixtureDef();
        platform.fixtureDef.shape = polygon;
        platform.body = physicsController.world.createBody(platform.bodyDef);
        platform.body.createFixture(platform.fixtureDef);
        platform.body.setUserData(platform);
    }

    // TODO: Remove this function from here
    public function createPlayer(world:B2World, player:ObjectModel):Void {
        //ALL THE MAGIC NUMBERS. REMEMBER TO FIX.
        player.id = "player";
        player.velocity.set(0,0);
        player.grounded = true;
        player.rotation = 0;
        player.left = false;
        player.right = false;
        player.width = 0.9;
        player.height = 1.9;
        player.bulletType = 1;
        
        player.bodyDef = new B2BodyDef();
        player.bodyDef.position.set(player.position.x, player.position.y);
        player.bodyDef.type = B2Body.b2_dynamicBody;
        player.bodyDef.allowSleep = false;
        player.bodyDef.fixedRotation = true;

        player.shape = new B2PolygonShape();
        player.shape.setAsBox ((player.width)/2, (player.height)/2);

        player.fixtureDef = new B2FixtureDef();
        player.fixtureDef.shape = player.shape;
        player.fixtureDef.density = 1;
        player.body = world.createBody(player.bodyDef);
        player.fixture = player.body.createFixture(player.fixtureDef);
        player.body.setUserData(player);
    }
    
    //TODO ADD ARGUMENTS FROM PARSER SO THAT RIGHT INFO IS USED
    public function createEnemy(world:B2World, enemy:ObjectModel) {
        enemy.id = "enemy";
        enemy.velocity.set(0,0);
        enemy.grounded = false;
        enemy.rotation = 0;
        enemy.left = false;
        enemy.right = false;
        enemy.width = 0.9;
        enemy.height = 1.9;
        enemy.bodyDef = new B2BodyDef();
        enemy.bodyDef.position.set(enemy.position.x, enemy.position.y);
        enemy.bodyDef.type = B2Body.b2_dynamicBody;
        enemy.bodyDef.fixedRotation = true;

        enemy.shape = new B2PolygonShape();
        enemy.shape.setAsBox ((enemy.width)/2, (enemy.height)/2);

        enemy.fixtureDef = new B2FixtureDef();
        enemy.fixtureDef.shape = enemy.shape;
        enemy.fixtureDef.friction = 1;
        enemy.fixtureDef.density = 1;
        enemy.body = world.createBody(enemy.bodyDef);
        enemy.fixture = enemy.body.createFixture(enemy.fixtureDef);
        enemy.body.setUserData(enemy);
    }
    
    public function createBullet(world:B2World, entity:ObjectModel,bullet:Projectile):Void {
        if (entity.bulletType == 0 ) {
            bullet.id = "melee";
            bullet.velocity.set(0, 0);
            bullet.dimension = new Point(5, 10);
            bullet.width = 32;
            bullet.height = 64;
        }
        else {
            if (entity.bulletType == 1 ) {
                bullet.id = "bullet";
            }
            if (entity.bulletType == 2 ) {
                bullet.id = "piercingbullet";
                //bullet.body.isSensor = true;
            }
            else{
                bullet.id = "explosivebullet";
            }
        //bullet.velocity.set(0,0);
        bullet.dimension = new Point(5, 10);
        bullet.width = 5;
        bullet.height = 10;
        }
        
        bullet.position = entity.position;
        
        if (entity.targetX > bullet.position.x) {
            bullet.position.x += 30;
        }
        if (entity.targetX < bullet.position.x) {
            bullet.position.x -= 30;
        }
        bullet.bodyDef = new B2BodyDef();
        bullet.bodyDef.position.set(bullet.position.x, bullet.position.y);
        bullet.bodyDef.type = B2Body.b2_dynamicBody;
        bullet.bodyDef.fixedRotation = true;
        bullet.bodyDef.bullet = true;
        //bullet.bodyDef.sensor = true;
        
        
        
        bullet.shape = new B2PolygonShape();
        bullet.shape.setAsBox ((bullet.width)/2, (bullet.height)/2);

        bullet.fixtureDef = new B2FixtureDef();
        bullet.fixtureDef.shape = bullet.shape;
        bullet.fixtureDef.friction = 1;
        bullet.fixtureDef.density = 1;
        bullet.fixtureDef.filter.maskBits = 0x0000;
        if (entity.bulletType == 2) {
        
            bullet.fixtureDef.isSensor = true;
        }
        
        bullet.body = world.createBody(bullet.bodyDef);
        
        bullet.fixture = bullet.body.createFixture(bullet.fixtureDef);
        bullet.body.setUserData(bullet.id);
    }
    
    public function updatePlayerRays(state:GameState):Void {
        //Update left Ray
        state.player.leftRayStart = new B2Vec2(state.player.position.x - (state.player.width/2), state.player.position.y - (state.player.height/2));
        state.player.leftRayEnd = new B2Vec2(state.player.leftRayStart.x, state.player.leftRayStart.y - 3);

        //Update right ray
        state.player.rightRayStart = new B2Vec2(state.player.position.x + (state.player.width/2), state.player.position.y - (state.player.height/2));
        state.player.rightRayEnd = new B2Vec2(state.player.rightRayStart.x, state.player.rightRayStart.y - 3);

        //Update left wall Ray
        state.player.leftWallRayStart = new B2Vec2(state.player.position.x - (state.player.width/2), state.player.position.y + (state.player.height/2));
        state.player.leftWallRayEnd = new B2Vec2(state.player.leftWallRayStart.x - 3, state.player.leftWallRayStart.y);

        //Update right wall ray
        state.player.rightWallRayStart = new B2Vec2(state.player.position.x - (state.player.width/2), state.player.position.y + (state.player.height/2));
        state.player.rightWallRayEnd = new B2Vec2(state.player.rightWallRayStart.x + 3, state.player.rightWallRayStart.y);
    }
    
    public function raycastLeftCallback(fixture:B2Fixture, point:B2Vec2, normal:B2Vec2, fraction:Float):Dynamic {
        if (fixture.getBody().getUserData() != null)
        {
            var o = fixture.getBody().getUserData();
            cast(o, ObjectModel);
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
            cast(o, ObjectModel);
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
            cast(o, ObjectModel);
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
            cast(o, ObjectModel);
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
    
    public function handleCollisions():Bool {
        for (contact in state.contactList) {
            // Check what was in collision
			if (contact != null) {
				var entity1 = cast(contact.getFixtureA().getBody().getUserData(), ObjectModel);
				var entity2 = cast(contact.getFixtureB().getBody().getUserData(), ObjectModel);
				var id1 = entity1.id;
				var id2 = entity2.id;
				
				/*
				//When a player is hit by normal bullet
				if ((id1 == "player" && id2 == "bullet") || (id2 == "player" && id1 == "bullet")) {
					//player takes damage;
					//mark bullet for destreuction
				}
				//If player is hit by melee
				}
				if ((id1 == "player" && id2 == "melee") || (id2 == "player" && id1 == "melee")) {
					//player takes damage;
				}
				if ((id1 == "player" && id2 == "piercingBullet") || (id2 == "player" && id1 == "piercingBullet")) {
					//player takes damage;
				}
				if ((id1 == "player" && id2 == "explosiveBullet") || (id2 == "player" && id1 == "explosiveBullet")) {
					//player takes damage;
					//mark bullet for destreuction;
					//spawn radial burst;
				}
				if ((id1 == "player" && id2 == "bulletBurst") || (id2 == "player" && id1 == "bulletBurst")) {
					//player takes damage;
					//burst disappears on its own so nothing else needed
				}
				*/
			}
			
            // TODO: Contact list should be a special tuple of <GameObjectType, Dynamic> to get correct casting results
        }
        
        return true;
    }
    
    public function update(s:GameState, gameTime:GameTime):Void {
        state = s;
        Spawner.spawn(gameTime, state);
        
        physicsController.update(gameTime.elapsed);
        for (entity in state.entities) {
            //UPDATES VELOCITY
            entity.velocity = entity.body.getLinearVelocity().copy();
			
			//Just in case -__-
            var moveSpeed = entity.grounded ? PLAYER_GROUND_ACCEL : PLAYER_AIR_ACCEL;
            if (entity.left) entity.velocity.x -= moveSpeed;
            if (entity.right) entity.velocity.x += moveSpeed;

            //Apply friction if there is no input command
            if (!entity.left && !entity.right) {
                var friction = entity.grounded ? PLAYER_GROUND_FRICTION : PLAYER_AIR_FRICTION;
                entity.velocity.x *= friction;
            }
            
            // Clamp speed to a maximum value
            entity.velocity.x = Math.min(PLAYER_MAX_SPEED, Math.max(-PLAYER_MAX_SPEED, entity.velocity.x));
//trace(entity.velocity.y);
            if (entity.up && entity.leftFootGrounded) {
                    entity.velocity.y = 10;
					
            }
		
			
            entity.body.setLinearVelocity(entity.velocity.copy()); //So that the velocity actually does something
//trace(entity.velocity.y);
            //UPDATE POSITION
            entity.position = entity.body.getPosition();   

            
            //TODO This should be its own function
            /*if (entity.click) {
                var bullet:Projectile = new Projectile();
                createBullet(physicsController.world, entity, bullet);
                bullet.targetX = entity.targetX;
                bullet.targetY = entity.targetY;
                bullet.setVelocity();
                state.bullets.push(bullet);  //push bullet onto gamestate bullets
            }*/
        }
        
        for (bullet in state.bullets) {
            bullet.body.setLinearVelocity(bullet.velocity);
        }
        
        //Update Raycast Rays. WILL CHANGE TO ENITITY IF NEEDED
        updatePlayerRays(state);
        Raycast(physicsController.world, state.player);
        

    }
}
