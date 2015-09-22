package;

/**
 * ...
 * @author Mark
 */
//{ Import Statements
	
	
//}

 
class PlayerController extends GameplayController
{
	//{ Fields 
	var player:ObjectModel;
	var START_POS:Point;
	//}	
	
	
	//{ Initialization
	public function new() 
	{
		super();
		player = new ObjectModel();
		player.setID("player");
		START_POS=new Point (150, 800);
		player.setPosition(START_POS);
		player.setGrounded(true);
		



	}
	//}
	
	
	//{ Game Loop
	
	public function update(gameTime:GameTime):Void 
	{
		throw "abstract";
	}
	








	//}
	

}