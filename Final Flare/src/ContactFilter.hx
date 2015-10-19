package;

import box2D.dynamics.contacts.B2Contact;
import box2D.dynamics.B2Fixture;
import box2D.dynamics.B2ContactFilter;


class ContactFilter extends B2ContactFilter
{
    
    private var state:GameState;
    
    public function new(s:GameState) 
    {
        super();
        state = s;
    }
    
    override public function shouldCollide(fixtureA:B2Fixture, fixtureB:B2Fixture):Bool 
    {
        var entity1 = cast(fixtureA.getBody().getUserData(), ObjectModel);
        var entity2 = cast(fixtureB.getBody().getUserData(), ObjectModel);
        var id1 = entity1.id;
        var id2 = entity2.id;
        
        if ((id1 == "Player" || id2 == "Player") && !state.player.isDead) {
            return false;
        }
        
        else if ((id1 == "player" && id2 == "enemy") 
        || (id2 == "player" && id1 == "enemy") 
        || (id1 == "platform" && id2 == "platform") 
        || (id1 == "enemy" && id2 == "enemy")) {
		|| (id1 == "bullet" && id2 == "platform")
		|| (id2 == "bullet" && id1 == "platform") {
            return false;
        }
        
        else 
        {
            return true;
        }
        
        return true;
        //return super.shouldCollide(fixtureA, fixtureB);
    }
}