/**
 * ...
 * @author Mark
 */
//{ Import Statements
package;

import box2D.dynamics.B2Body;
import box2D.dynamics.B2BodyType;
import openfl.geom.Point;
//}


class ObjectModel
{
    //{ Fields

    public static var MAX_SPEED:Float = 8;

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

    //TODO write getters and setters
    public var direction:Int;      //-1 for left, 1 for right, 0 otherwise
    public var canShoot:Bool;
    public var canJump:Bool;
    public var left:Bool;          //Can move left
    public var right:Bool;         //Can move right
    public var grounded:Bool;      //True if touching a platform

    //}6

    //{ Initialization
    public function new()
    {
    }
    //}
}
