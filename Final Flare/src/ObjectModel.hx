


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
	var body:B2Body;
	var bodyType:B2BodyType;
	
	//Phsyics data
	var position Point; 	//Object position
	var velocity:Point; 	//Object velocity    
	var rotation:Float; 	//Rotation	
	var grounded:Bool;		//True if touching a platform
	
	//Drawing Fields
	var textureSize:Point;  //Texture Size
	var dimension:Point;    //Dimensions of box, for drawing purposes
    var scale:Point;        //Used to scale texture
	
	//}
	
	
	//{Getters and Setters
	
	//}
	
	
	//{ Initialization
	public function new() 
	{
		//THERE SHOULDN'T BE ANYTHING HERE
		super();		
	}
	//}


	

