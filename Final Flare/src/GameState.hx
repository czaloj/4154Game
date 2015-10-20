package;

import flash.display.Sprite;
import box2D.dynamics.contacts.B2Contact;

class GameState {
    //dimension of map in tiles

    public static var world_sprite:Sprite;

    public var width = 0;
    public var height = 0;

    public var foreground:Array<Int> = [];
    public var background:Array<Int> = [];

    public var spawners:Array<Spawner> = [];

    public var player:ObjectModel;
    public var entities:List<ObjectModel> = new List();

    public var contactList:List<B2Contact> = new List();
    public var bullets:Array<Projectile> = [];
    public var markedForDeletion:Array<Entity> = [];
    
    // Broadcasting events
    public var onEntityAdded:BroadcastEvent2<GameState, ObjectModel> = new BroadcastEvent2<GameState, ObjectModel>();
    public var onEntityRemoved:BroadcastEvent2<GameState, ObjectModel> = new BroadcastEvent2<GameState, ObjectModel>();
    public var onProjectileAdded:BroadcastEvent2<GameState, Projectile> = new BroadcastEvent2<GameState, Projectile>();
    public var onProjectileRemoved:BroadcastEvent2<GameState, Projectile> = new BroadcastEvent2<GameState, Projectile>();
    
    public function new() {
        // Empty
    }
}
