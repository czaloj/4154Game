package game;

import box2D.dynamics.contacts.B2Contact;
import flash.display.Sprite;
import game.damage.DamageDealer;
import game.events.GameEvent;

class GameState {
    public static var world_sprite:Sprite;

    // Dimension of map in half-tiles
    public var width = 0;
    public var height = 0;

    public var foreground:Array<Int> = [];
    public var background:Array<Int> = [];

    public var spawners:Array<Spawner> = [];

    public var player:ObjectModel;
    public var entities:List<ObjectModel> = new List<ObjectModel>();
    public var damage:List<DamageDealer> =  new List<DamageDealer>();

    public var contactList:List<B2Contact> = new List();
    public var bullets:Array<Projectile> = [];
    
    public var gameEvents:Array<GameEvent> = []; // The queue of game events that should occur during an update
    
    // Broadcasting events
    public var onEntityAdded:BroadcastEvent2<GameState, ObjectModel> = new BroadcastEvent2<GameState, ObjectModel>();
    public var onEntityRemoved:BroadcastEvent2<GameState, ObjectModel> = new BroadcastEvent2<GameState, ObjectModel>();
    public var onProjectileAdded:BroadcastEvent2<GameState, game.Projectile> = new BroadcastEvent2<GameState, game.Projectile>();
    public var onProjectileRemoved:BroadcastEvent2<GameState, game.Projectile> = new BroadcastEvent2<GameState, game.Projectile>();
    
    public function new() {
        // Empty
    }
}
