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

 
class GameplayController extends GameScreen
{
	//{ Fields 
	
	var id:String;          //Identifying tag  
	
	//Box2D Fields
	private var body:B2Body;
	privatevar bodyType:B2BodyType;
	
	//Phsyics data
	private var position Point; 	//Object position
	private var velocity:Point; 	//Object velocity    
	private var rotation:Float; 	//Rotation	
	private var grounded:Bool;		//True if touching a platform
	
	//Drawing Fields
	private var textureSize:Point;  //Texture Size
	private var dimension:Point;    //Dimensions of box, for drawing purposes
    private var scale:Point;        //Used to scale texture
	
	//}
	
	
	//{Getters and Setters
	public function getId() 
	{
		return id;
	}
	
	public function setId(s:String) 
	{
		id = s;
	}
	
	public function getPosition() 
	{
		return position;
	}
	public function setPosition(p:Point) 
	{
		position = p;
	}
	
	public function getVelocity() 
	{
		return velocity;
	}
	public function setVelocity(v:Point) 
	{
		velocity = v;
	}
	
	public function getRotation() 
	{
		return rotation;
	}
	public function setRotation(r:Float) 
	{
		rotation = r;
	}
	
	public function getGrounded() 
	{
		return rotation;
	}
	public function setGrounded(b:Bool) 
	{
		grounded = b;
	}
	
	public function getTextureSize() 
	{
		return textureSize;
	}
	public function setTextureSize(p:Point) 
	{
		textureSize = p;
	}
	
	public function getDimension() 
	{
		return dimension;
	}
	public function setDimension(p:Point) 
	{
		dimension = p;
	}
	
	public function getScale() 
	{
		return scale;
	}
	public function Scale(p:Point) 
	{
		scale = p;
	}	
	
	//}
	
	
	//{ Initialization
	public function new() 
	{
		//THERE SHOULDN'T BE ANYTHING HERE
		super();		
	}
	//}


	

