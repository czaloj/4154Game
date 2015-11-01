package game;

import box2D.dynamics.contacts.B2Contact;
import flash.display.Sprite;
import game.damage.DamageDealer;
import game.events.GameEvent;
import game.PhysicsController.PhysicsContact;

class GameState {
    public static var world_sprite:Sprite;

    // Dimension of map in half-tiles
    public var width = 0;
    public var height = 0;

    public var foreground:Array<Int> = [];
    public var background:Array<Int> = [];
    public var platforms:Array<Platform>;

    public var spawners:Array<Spawner> = [];

    public var player:Entity;
    public var entities:List<Entity> = new List<Entity>();
    public var damage:List<DamageDealer> =  new List<DamageDealer>();

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
        // Empty
    }
}
