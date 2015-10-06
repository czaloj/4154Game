package;

import openfl.geom.Point;
import box2D.dynamics.B2Body;
import box2D.dynamics.B2BodyDef;
import box2D.dynamics.B2Fixture;
import box2D.dynamics.B2FixtureDef;
import box2D.collision.shapes.B2PolygonShape;
import box2D.common.math.B2Vec2;

import box2D.dynamics.B2World;

class PlayerController {
	
	private static var PHYSICS_SCALE:Float = 1 / 30;
    
	public function new(player:ObjectModel, world:B2World) 
	{
        init(player, world);
    }

    public function update(player:ObjectModel, gameTime:GameTime):Void {
        // Move the player on conditional speed
        var moveSpeed = 3;//player.grounded ? .55 : .35;
        if (player.left) player.velocity.x -= moveSpeed;
        if (player.right) player.velocity.x += moveSpeed;

       	if (player.down) player.velocity.y -= moveSpeed;
        if (player.up) player.velocity.y += moveSpeed;
        
        // It seems we want to do conditional friction?
        if (!player.left && !player.right && !player.up && !player.down) {
            var friction = player.grounded ? .3 : .85;
            player.velocity.x *= friction;
        }
        
        // Clamp speed to a maximum value		
        player.velocity.x = Math.min(ObjectModel.MAX_SPEED, Math.max( -ObjectModel.MAX_SPEED, player.velocity.x));

		//ayer.position = player.body.getPosition();
		//ayer.body.setLinearVelocity(player.velocity);
		


		//player.velocity.y -= 2;
		//player.position.y = player.body.getPosition().y;
		//var pos:B2Vec2 = player.body.getPosition();
		if (player.position.x > 400) player.position = new B2Vec2(400.0,player.position.y);
		if (player.position.x < -400) player.position = new B2Vec2(-400.0,player.position.y);		
		if (player.position.y > 250) player.position = new B2Vec2(player.position.x,250);
		if (player.position.y < -250) player.position = new B2Vec2(player.position.x,-250);
	
		//player.position = pos;
		
		//player.body.setLinearVelocity(player.velocity);
		//var vector:B2Vec2 = new B2Vec2(10,10);
		//player.position = vector;
    	player.position = new B2Vec2(player.position.x+player.velocity.x,player.position.y+player.velocity.y);
    }
	
	
	private function init(player:ObjectModel, world:B2World):Void 
	{		
		
		//ALL THE MAGIC NUMBERS. REMEMBER TO FIX.
        player.id = "platform";
        player.position.set(0, 0);
        player.grounded = false;
        player.rotation = 0;
        player.velocity.set(0,0);
        player.left = false;
        player.right = false;
		player.dimension = new Point(32, 64);
		player.height = 64;
		player.width - 32;
		initPhysics(player, world);
	}
	
	private function initPhysics (player:ObjectModel, world:B2World):Void 
	{
 
		player.bodyDef = new B2BodyDef();
		player.bodyDef.position.set(player.position.x * PHYSICS_SCALE, player.position.y * PHYSICS_SCALE);
		player.bodyDef.type = B2Body.b2_dynamicBody;
	 
		var polygon = new B2PolygonShape ();
		polygon.setAsBox ((player.width / 2) * PHYSICS_SCALE, (player.height / 2) * PHYSICS_SCALE);
	 
		player.fixtureDef = new B2FixtureDef();
		player.fixtureDef.shape = polygon;
		player.fixtureDef.density = .001; 
		player.body = world.createBody(player.bodyDef);
		player.body.createFixture(player.fixtureDef);
		player.body.setUserData(player.id);
		player.body.setPosition(player.position);

	}	
}
