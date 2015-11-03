package graphics;

import game.Entity;
import starling.display.Sprite;

class EntitySprite extends Sprite {
    public static inline var POSE_REST:Int = 0;
    public static inline var POSE_RUN:Int = 1;
    public static inline var POSE_JUMP:Int = 2;
    
    public var data:EntityRenderData;
    public var headCenter:Sprite;
    public var head:StaticSprite;
    public var bodyRest:AnimatedSprite;
    public var bodyRun:AnimatedSprite;
    public var bodyJump:AnimatedSprite;
    public var bodyDeath:AnimatedSprite;
    public var bodyPoses:Array<AnimatedSprite>;
    private var pose:Int;
    
    public function new(s:SpriteSheet, e:EntityRenderData) {
        super();
        data = e;
        
        head = new StaticSprite(s, data.entityType + EntityRenderData.SPRITE_HEAD);
        head.width = data.widthHead;
        head.height = data.heightHead;
        head.x = data.headSpriteOffset.x;
        head.y = data.headSpriteOffset.y;
        
        bodyRest = new AnimatedSprite(s, data.entityType + EntityRenderData.ANIMATION_REST, data.animationDelays[0]);
        bodyRun = new AnimatedSprite(s, data.entityType + EntityRenderData.ANIMATION_RUN, data.animationDelays[1]);
        bodyJump = new AnimatedSprite(s, data.entityType + EntityRenderData.ANIMATION_JUMP, data.animationDelays[2]);
        bodyJump.loop = false;
        bodyPoses = [
            bodyRest,
            bodyRun,
            bodyJump
        ];
        for (i in 0...3) {
            bodyPoses[i].x = data.bodySpriteOffset.x;
            bodyPoses[i].y = data.bodySpriteOffset.y;
            bodyPoses[i].width = data.widthBody;
            bodyPoses[i].height = data.heightBody;
        }
        
        // Initial view
        headCenter = new Sprite();
        headCenter.addChild(head);
        pose = 0;
        addChild(bodyPoses[pose]);
        addChild(headCenter);
    }
    
    public function switchTo(p:Int) {
        if (p != pose) {
            removeChild(bodyPoses[pose]);
            pose = p;
            addChild(bodyPoses[pose]);
        }
        
        bodyPoses[pose].reset();
    }
    
    public function recalculate(e:Entity) {
        x = e.position.x;
        y = e.position.y;
        var as:AnimatedSprite = bodyPoses[pose];
        as.scaleX = Math.abs(as.scaleX) * e.lookingDirection;
        as.x = data.bodySpriteOffset.x * e.lookingDirection;
        headCenter.x = e.headOffset.x  * e.lookingDirection;
        headCenter.y = e.headOffset.y;
        headCenter.rotation = e.headAngle;
        headCenter.scaleY = e.lookingDirection;
    }
}
