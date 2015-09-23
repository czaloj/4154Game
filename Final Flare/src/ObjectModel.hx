package;

import box2D.dynamics.B2Body;
import box2D.dynamics.B2BodyType;
import openfl.geom.Point;

class ObjectModel {
    public static var MAX_SPEED:Float = 8.0;

    public var id:String;          //Identifying tag

    //Box2D Fields
    private var body:B2Body;
    private var bodyType:B2BodyType;

    //Phsyics data
    public var position:Point = new Point();     //Object position
    public var velocity:Point = new Point();     //Object velocity
    public var rotation:Float;     //Rotation

    //Drawing Fields
    public var textureSize:Point = new Point();  //Texture Size
    public var dimension:Point = new Point();    //Dimensions of box, for drawing purposes
    public var scale:Point = new Point();        //Used to scale texture

    //Input Flags
    public var direction:Int;      //-1 for left, 1 for right, 0 otherwise
    public var canShoot:Bool;
    public var canJump:Bool;
    public var left:Bool;          //Can move left
    public var right:Bool;         //Can move right
    public var grounded:Bool;      //True if touching a platform

    public function new() {
        // Empty
    }
}
