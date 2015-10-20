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
        state.contactList.add(contact);
    }
    
    override public function endContact(contact:B2Contact):Void 
    {
        super.endContact(contact); //Does literally nothing atm
    }
    
}