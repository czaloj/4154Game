package sound;
import haxe.ds.StringMap;
import openfl.events.Event;
import openfl.events.TimerEvent;
import openfl.Lib;
import openfl.media.Sound;
import openfl.media.SoundChannel;
import openfl.media.SoundTransform;
import openfl.net.URLRequest;
import openfl.utils.Timer;

class Composer {
    @:isVar public static var levelMaster(default, set):Float = 1.0;
    @:isVar public static var levelMusic(default, set):Float = 1.0;
    @:isVar public static var levelEffects(default, set):Float = 1.0;
    public static var isLoadingComplete(get, never):Bool;
    public static var isStreamingComplete(get, never):Bool;
    
    private static var transformMusic:SoundTransform = new SoundTransform(1, 0);
    private static var transformEffects:SoundTransform = new SoundTransform(1, 0);

    private static var sounds:StringMap<Sound> = new StringMap<Sound>();
    private static var effects:StringMap<Sound> = new StringMap<Sound>();
    private static var effectsToLoad:Int = 2;
    private static var soundsToLoad:Int = 6;
    
    private static var musicInstances:Array<SoundChannel> = [];
    private static var effectInstances:Array<SoundChannel> = [];
    
    public static function loadTracks():Void {
        var fLoadCallbackMusic:Dynamic->Void = function(e:Event):Void { soundsToLoad -= 1; };
        var fLoadCallbackEffects:Dynamic->Void = function(e:Event):Void { soundsToLoad -= 1; effectsToLoad -= 1; };
        
        // Music tracks
        var s:Sound = new Sound(new URLRequest("http://gdiac.cis.cornell.edu/gallery/flash/2015fa/finalflare/files/music/Hero - Wisp X.mp3"));
        s.addEventListener(Event.COMPLETE, fLoadCallbackMusic);
        sounds.set("Menu1", s);
        s = new Sound(new URLRequest("http://gdiac.cis.cornell.edu/gallery/flash/2015fa/finalflare/files/music/Villain - Wisp X.mp3"));
        s.addEventListener(Event.COMPLETE, fLoadCallbackMusic);
        sounds.set("Menu2", s);
        s = new Sound(new URLRequest("http://gdiac.cis.cornell.edu/gallery/flash/2015fa/finalflare/files/music/Cruncher - Wisp X.mp3"));
        s.addEventListener(Event.COMPLETE, fLoadCallbackMusic);
        sounds.set("Menu3", s);
        s = new Sound(new URLRequest("http://gdiac.cis.cornell.edu/gallery/flash/2015fa/finalflare/files/music/Vibrance - Wisp X.mp3"));
        s.addEventListener(Event.COMPLETE, fLoadCallbackMusic);
        sounds.set("Menu4", s);
        
        // Effects
        s = new Sound(new URLRequest("http://gdiac.cis.cornell.edu/gallery/flash/2015fa/finalflare/files/effects/Shot.mp3"));
        s.addEventListener(Event.COMPLETE, fLoadCallbackEffects);
        effects.set("Shot", s);
        s = new Sound(new URLRequest("http://gdiac.cis.cornell.edu/gallery/flash/2015fa/finalflare/files/effects/Bomb.mp3"));
        s.addEventListener(Event.COMPLETE, fLoadCallbackEffects);
        effects.set("Bomb", s);
    }
    
    public static function playMusicTrack(name:String):SoundChannel {
        var s:Sound = sounds.get(name);
        var channel:SoundChannel = s.play(0, 0, transformMusic);
        channel.addEventListener(Event.SOUND_COMPLETE, function(e:Event):Void {
            musicInstances.remove(channel);
        });
        musicInstances.push(channel);
        return channel;
    }
    public static function playEffect(name:String):SoundChannel {
        var s:Sound = effects.get(name);
        var channel:SoundChannel = s.play(0, 1, transformEffects);
        channel.addEventListener(Event.SOUND_COMPLETE, function(e:Event):Void {
            effectInstances.remove(channel);
        });
        effectInstances.push(channel);
        return channel;
    }
    
    private static function updateInstances(a:Array<SoundChannel>, t:SoundTransform):Void {
        for (c in a) c.soundTransform = t;
    }
    
    private static function set_levelMaster(v:Float):Float {
        levelMaster = v;
        transformMusic.volume = levelMaster * levelMusic;
        updateInstances(musicInstances, transformMusic);
        transformEffects.volume = levelMaster * levelEffects;
        updateInstances(effectInstances, transformEffects);
        return levelMaster;
    }
    private static function set_levelMusic(v:Float):Float {
        levelMusic = v;
        transformMusic.volume = levelMaster * levelMusic;
        updateInstances(musicInstances, transformMusic);
        return levelMusic;
    }
    private static function set_levelEffects(v:Float):Float {
        levelEffects = v;
        transformEffects.volume = levelMaster * levelEffects;
        updateInstances(effectInstances, transformEffects);
        return levelEffects;
    }
    private static function get_isLoadingComplete():Bool {
        return effectsToLoad == 0;
    }
    private static function get_isStreamingComplete():Bool {
        return soundsToLoad == 0;
    }
    
    public function new() {
        // Empty
    }
}
