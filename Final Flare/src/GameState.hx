package;

import flash.display.Sprite;

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




    public function new() {
        // Empty
    }
}
