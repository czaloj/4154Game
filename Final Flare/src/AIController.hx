package;

import openfl.geom.Point;
import box2D.dynamics.B2World;
import box2D.dynamics.B2Body;
import box2D.dynamics.B2BodyDef;
import box2D.dynamics.B2Fixture;
import box2D.dynamics.B2FixtureDef;
import box2D.collision.shapes.B2PolygonShape;
import box2D.common.math.B2Vec2;

class AIController {
    public function new(entity:ObjectModel, world:B2World) {
        // TODO: this should be initialized elsewhere?
        entity.grounded = false;
        entity.rotation = 0;
        entity.velocity.set(0,0);
        entity.left = false;
        entity.right = false;
        entity.dimension = new Point(32, 64);
        entity.height = 64;
        entity.width - 32;
        initPhysics(entity, world);
    }

    private function initPhysics (entity:ObjectModel, world:B2World):Void 
    {
 
        entity.bodyDef = new B2BodyDef();
        entity.bodyDef.position.set(entity.position.x * PHYSICS_SCALE, entity.position.y * PHYSICS_SCALE);
        entity.bodyDef.type = B2Body.b2_dynamicBody;
     
        var polygon = new B2PolygonShape ();
        polygon.setAsBox ((entity.width / 2) * PHYSICS_SCALE, (entity.height / 2) * PHYSICS_SCALE);
     
        entity.fixtureDef = new B2FixtureDef();
        entity.fixtureDef.shape = polygon;
        entity.fixtureDef.density = .001; 
        entity.body = world.createBody(entity.bodyDef);
        entity.body.createFixture(entity.fixtureDef);
        entity.body.setUserData(entity.id);

    }

    public function update(state:GameState):Void {
        // Move the entity on conditional speed
        var moveSpeed = entity.grounded ? .55 : .35;
        if (entity.left) entity.velocity.x -= moveSpeed;
        if (entity.right) entity.velocity.x += moveSpeed;
        
        // It seems we want to do conditional friction?
        if (!entity.left && !entity.right) {
            var friction = entity.grounded ? .3 : .85;
            entity.velocity.x *= friction;
        }
        
        // Clamp speed to a maximum value        
        entity.velocity.x = Math.min(ObjectModel.MAX_SPEED, Math.max( -ObjectModel.MAX_SPEED, entity.velocity.x));
        
        entity.position = entity.body.getPosition();
        var pos:B2Vec2 = entity.body.getPosition();
        if (pos.x > 10) pos = new B2Vec2(10.0,pos.y);
        if (pos.x < -10) pos = new B2Vec2(-10.0,pos.y);
        if (pos.y > 10) pos = new B2Vec2(pos.x,10.0);
        if (pos.y < -10) pos = new B2Vec2(pos.x,-10.0);
        entity.position = pos;
        
        entity.body.setLinearVelocity(entity.velocity);
    }
}
