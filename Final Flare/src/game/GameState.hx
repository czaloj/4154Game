package game;

import box2D.dynamics.contacts.B2Contact;
import flash.display.Sprite;
import game.damage.DamageDealer;
import game.events.GameEvent;
import game.GameState.EntityNonNullList;
import game.PhysicsController.PhysicsContact;
import weapon.WeaponData;

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
    public var damage:Array<DamageDealer> =  new Array<DamageDealer>();

    public var contactList:List<PhysicsContact> = new List<PhysicsContact>();
    public var projectiles:Array<Projectile> = [];

    public var gameEvents:Array<GameEvent> = []; // The queue of game events that should occur during an update
    
    // Broadcasting events
    public var onEntityAdded:BroadcastEvent2<GameState, Entity> = new BroadcastEvent2<GameState, Entity>();
    public var onEntityRemoved:BroadcastEvent2<GameState, Entity> = new BroadcastEvent2<GameState, Entity>();
    public var onProjectileAdded:BroadcastEvent2<GameState, game.Projectile> = new BroadcastEvent2<GameState, game.Projectile>();
    public var onProjectileRemoved:BroadcastEvent2<GameState, game.Projectile> = new BroadcastEvent2<GameState, game.Projectile>();

    public var score:Int = 0;
    public function new() {
        entitiesNonNull = new EntityNonNullList(this);
    }
}
