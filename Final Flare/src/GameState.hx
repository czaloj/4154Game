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
    public var entities:Array<ObjectModel> = [];

    public var contactList:List<B2Contact> = new List();
    public var bullets:Array<Projectile> = [];

    
    public function new() {
        // Empty
    }
}
