package game;

import box2D.dynamics.contacts.B2Contact;
import flash.display.Sprite;
import game.damage.DamageDealer;
import game.events.GameEvent;
import game.GameState.EntityNonNullList;
import game.PhysicsController.PhysicsContact;
import weapon.projectile.BulletProjectile;
import weapon.WeaponData;

//{ Non-null Entities Iterator
class EntityNonNullIterator{
    private var list:Array<Entity>;
    private var i:Int = 0;
    
    public function new(l:Array<Entity>) {
        list = l;
    }
    
    public function hasNext():Bool {
        while ((i < list.length) && (list[i] == null)) i++;
        return i < list.length;
    }
    public function next():Entity {
        return list[i++];
    }
}
class EntityNonNullList {
    private var state:GameState;
    
    public function new(s:GameState) {
        state = s;
    }
    
    public function iterator():Iterator<Entity> {
        return new EntityNonNullIterator(state.entities);
    }
}
//}

//{ Enabled Entities Iterator
class EntityEnabledIterator{
    private var list:Array<Entity>;
    private var i:Int = 0;
    
    public function new(l:Array<Entity>) {
        list = l;
    }
    
    public function hasNext():Bool {
        while ((i < list.length) && (list[i] == null || !list[i].enabled)) i++;
        return i < list.length;
    }
    public function next():Entity {
        return list[i++];
    }
}
class EntityEnabledList {
    private var state:GameState;
    
    public function new(s:GameState) {
        state = s;
    }
    
    public function iterator():Iterator<Entity> {
        return new EntityEnabledIterator(state.entities);
    }
}
//}

class GameState {
    public static var world_sprite:Sprite;

    // Dimension of map in half-tiles
    public var width = 0;
    public var height = 0;

    public var foreground:Array<Int> = [];
    public var background:Array<Int> = [];
    public var platforms:Array<Platform>;

    // Weapons used in the level
    public var characterWeapons:Array<WeaponData>;
    public var enemyWeapons:Array<WeaponData>;
    
    public var spawners:Array<Spawner> = [];

    public var player:Entity;
    public var entities:Array<Entity> = new Array<Entity>();
    public var entitiesNonNull:EntityNonNullList;
    public var entitiesEnabled:EntityEnabledList;
    public var damage:Array<DamageDealer> =  new Array<DamageDealer>();

    public var contactList:List<PhysicsContact> = new List<PhysicsContact>();
    public var projectiles:Array<BulletProjectile> = [];

    public var gameEvents:Array<GameEvent> = []; // The queue of game events that should occur during an update
    
    public var score:Int = 0;
    
    public function new() {
        entitiesNonNull = new EntityNonNullList(this);
        entitiesEnabled = new EntityEnabledList(this);
    }
}
