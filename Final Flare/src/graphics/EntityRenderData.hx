package graphics;

import openfl.geom.Point;

class EntityRenderData {
    public static inline var SPRITE_HEAD:String = ".Head";
    public static inline var ANIMATION_REST:String = ".Rest";
    public static inline var ANIMATION_RUN:String = ".Run";
    public static inline var ANIMATION_JUMP:String = ".Jump";
    public static inline var ANIMATION_DEATH:String = ".Death";
    
    // Placement and dimensions of the body sprite
    public var bodySpriteOffset:Point = new Point();
    public var widthBody:Float = 1.0;
    public var heightBody:Float = 1.0;

    // Placement and dimensions of the head sprite
    public var headSpriteOffset:Point = new Point();
    public var widthHead:Float = 1.0;
    public var heightHead:Float = 1.0;
    
    // The sprite to use for the body and head
    public var entityType:String;
    
    // Speeds for the different animations (Rest, Run, Jump, Death)
    public var animationDelays:Array<Int>;
    
    public function new(type:String) {
        entityType = type;
        SpriteSheetRegistry.fillEntityRenderData(this);
    }
}
