package;
import openfl.net.SharedObject;
import weapon.WeaponData;
import weapon.WeaponGenerator;

class PlayerData {
    // The cached player data
    private var so:SharedObject;
    
    // Weapons the player has unlocked
    public var weapons(get, never):Array<WeaponData>;
    public var points(get, set):Int;
    
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
        v.points = 1000;
        
        // Fill temps
        v.mostRecentScore = 0;
        v.mostRecentVictory = false;
    }
    public function reset():Void {
        so.clear();
        generateDefault(so.data);
        so.flush();
    }

    public function get_points():Int {
        return so.data.points;
    }
    public function set_points(v:Int):Int {
        so.data.points = v;
        return so.data.points;
    }
    
    public function get_weapons():Array<WeaponData> {
        return so.data.weapons;
    }
    public function addWeapon(w:WeaponData) {
        so.data.weapons.push(w);
    }
}