package game;

import box2D.dynamics.B2ContactListener;
import box2D.dynamics.contacts.B2Contact;
import game.GameState;

class ContactListener extends B2ContactListener
{
    private var state:game.GameState;
    public static var BULLET_DAMAGE = 10;
    public static var MELEE_DAMAGE = 20;
    public function new(s:game.GameState) 
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