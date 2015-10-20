package;

import box2D.dynamics.B2ContactListener;
import box2D.dynamics.contacts.B2Contact;

class ContactListener extends B2ContactListener
{
    private var state:GameState;
	public static var BULLET_DAMAGE = 10;
	public static var MELEE_DAMAGE = 20;
    public function new(s:GameState) 
    {
        super();
        state = s;
    }
    
    override function beginContact(contact:B2Contact):Void 
    { 
		
				trace("begun");
                var entity1 = cast(contact.getFixtureA().getBody().getUserData(), Entity);
                var entity2 = cast(contact.getFixtureB().getBody().getUserData(), Entity);
                var id1 = entity1.id;
                var id2 = entity2.id;
				trace("id1"+id1+"id2"+id2);
				
                
                //When a player is hit by normal bullet
                if ((id1 == "player" || id1 == "enemy") && id2 == "bullet") {
					var entity1o = cast(entity1, ObjectModel);
					entity1o.health -= BULLET_DAMAGE;
					trace("contact");
				}
				
				if((id2 == "player" || id2 =="enemy") && id1 == "bullet") {
					var entity2o = cast(entity2, ObjectModel);
					entity2o.health -= BULLET_DAMAGE;
					trace("contact");
					//player takes damage;
                    //mark bullet for destreuction
                }
				if ((id1 == "player" || id1 == "enemy") && id2 == "melee") {
					var entity1o = cast(entity1, ObjectModel);
					entity1o.health -= MELEE_DAMAGE;
					trace("contact");
				}
				
				if((id2 == "player" || id2 =="enemy") && id1 == "melee") {
					var entity2o = cast(entity2, ObjectModel);
					entity2o.health -= MELEE_DAMAGE;
					trace("contact");
					//player takes damage;
                    //mark bullet for destreuction
                }
        //state.contactList.add(contact);
    }
    
    override public function endContact(contact:B2Contact):Void 
    {
        super.endContact(contact); //Does literally nothing atm
    }
    
}