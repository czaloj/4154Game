package;
import haxe.Serializer;
import haxe.Unserializer;
import openfl.net.SharedObject;
import openfl.net.SharedObjectFlushStatus;
import weapon.WeaponData;
import weapon.WeaponGenerator;

class PlayerData {
    // The cached player data
    private var so:SharedObject;
    
    // Weapons the player has unlocked
    public var weapons(get, never):Array<WeaponData>;
    public var pointsEvolution(get, set):Int;
    public var pointsHistorical(get, set):Int;
    public var pointsShadyness(get, set):Int;
    
    // Record-keeping values
    public var selectedChars:Array<String> = new Array<String>();
	public var mostRecentScore:Int;
	public var mostRecentVictory:Bool;
    
    public function new(playerName:String) {
        // Load from the flash cache or generate default if it doesn't exist
        so = SharedObject.getLocal("FinalFlare_" + playerName);
        if (!Reflect.hasField(so.data, "init")) {
            generateDefault(so.data);
        }
    }
    
    private function generateDefault(v:Dynamic) {
        // Have a flag cookie
        v.init = true;

        // Initial player setup
        v.weapons = WeaponGenerator.generateInitialWeapons();
        v.pointsEvolution = 1000;
        v.pointsHistorical = 100;
        v.pointsShadyness = 100;
        
        // Fill temps
        v.mostRecentScore = 0;
        v.mostRecentVictory = false;
    }
    public function reset():Void {
        so.clear();
        generateDefault(so.data);
        save();
    }
    public function save():Void {
        so.flush();
    }
    
    public function get_pointsEvolution():Int {
        return so.data.pointsEvolution;
    }
    public function set_pointsEvolution(v:Int):Int {
        so.data.pointsEvolution = v;
        return so.data.pointsEvolution;
    }
    
    public function get_pointsHistorical():Int {
        return so.data.pointsHistorical;
    }
    public function set_pointsHistorical(v:Int):Int {
        so.data.pointsHistorical = v;
        return so.data.pointsHistorical;
    }
    
    public function get_pointsShadyness():Int {
        return so.data.pointsShadyness;
    }
    public function set_pointsShadyness(v:Int):Int {
        so.data.pointsShadyness = v;
        return so.data.pointsShadyness;
    }
    
    public function get_weapons():Array<WeaponData> {
        return so.data.weapons;
    }
    public function addWeapon(w:WeaponData) {
        so.data.weapons.push(w);
    }
}