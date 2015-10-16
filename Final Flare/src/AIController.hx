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
    public var entities:Array<ObjectModel>;

    public function new() {
    }

    public function move(state:GameState):Void {
        for (entity in state.entities) {
            if (entity.id != "player") {

            }
        }
    }
}
