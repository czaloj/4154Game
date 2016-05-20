package game;

import haxe.ds.IntMap;
import haxe.ds.ObjectMap;
import openfl.geom.Point;
import box2D.dynamics.contacts.B2Contact;
import flash.display.Sprite;
import game.damage.DamageDealer;
import game.events.GameEvent;
import game.GameState.EntityNonNullList;
import game.PhysicsController.PhysicsContact;
import weapon.projectile.Projectile;
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
    // Dimension of map in half-tiles
    public var width = 0;
    public var height = 0;

    // Map information
    public var foreground:Array<Int> = [];
    public var background:Array<Int> = [];
    public var platforms:Array<Platform>;
    public var spawners:Array<Spawner> = [];
    public var regions:Array<Int> = [];
    public var nregions:Int = 0;
    public var regionLists:IntMap<Region> = new IntMap<Region>();
    public var pathTbl:IntMap<IntMap<Int>> = new IntMap<IntMap<Int>>();

    // Weapons used in the level
    public var characterWeapons:Array<WeaponData>; // The first 5 weapons correspond to the weapons the players receive, the sixth is the flare gun used between all the players
    public var enemyWeapons:Array<WeaponData>;

    // Time-keeping information
    public var time:GameTime = new GameTime();
    public var timeMultiplier:Float = 1.0; // Can be used to speed-up or slow-down the state simulation
	public var markedtime:Float;
    // Game object information
    public var charList:Array<String> = new Array<String>();
    public var player:Entity;
    public var entities:Array<Entity> = new Array<Entity>();
    public var entitiesNonNull:EntityNonNullList;
    public var entitiesEnabled:EntityEnabledList;
    public var projectiles:Array<Projectile> = [];

    // Important event queues
    public var gameEvents:Array<GameEvent> = []; // The queue of game events that should occur during an update
    public var damage:Array<DamageDealer> =  new Array<DamageDealer>();
    public var contactList:List<PhysicsContact> = new List<PhysicsContact>();

    // Difficulty tracking
    public var difficulty:Float = 0.0;

    // Flare information
    public var flares:Int = 5;
    public var flareCountdown:Float = 0.0;
    public var flaredEntity:Int = 0; // When a flare event comes in, this indexed entity will replace the player

    // Scoring information
    public var score:Int = 0;
    public var scoreThreshold:Int = 20;
    public var accumulatedEvolution:Int = 0;
    public var accumulatedHistorical:Int = 0;
    public var accumulatedShadyness:Int = 0;
    
    public var victory:Bool;
    public var gameOver:Bool;
    public var bossFought:Bool = false;
    public var comboMultiplier:Int = 1; // How much score is multiplied before being applied to the total score
    public var comboPercentComplete:Float = 0.0; // Ratio of how many points left until the next combo level (0-1)

    public function new() {
        entitiesNonNull = new EntityNonNullList(this);
        entitiesEnabled = new EntityEnabledList(this);

        time.elapsed = 0.0;
        time.total = 0.0;
        time.frame = 0;
    }
}
