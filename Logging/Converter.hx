package;

import openfl.events.Event;
import flash.net.FileReference;
import flash.utils.ByteArray;
import flash.net.URLRequest;
import haxe.Serializer;
import haxe.Json;


class Converter {
    public static function main():Void {
        var fileRef:FileReference = new FileReference();
        fileRef.addEventListener(Event.SELECT, onFileBrowse);
        fileRef.browse();
    }
    
    public static function onFileBrowse(e:openfl.events.Event):Void {
        var fileRef:FileReference = cast(e.target, FileReference);
        fileRef.removeEventListener(Event.SELECT, onFileBrowse);
        fileRef.addEventListener(Event.COMPLETE, onFileLoaded);
        fileRef.load();
    }
    public static function onFileLoaded(e:openfl.events.Event):Void {
        var fileReference:FileReference = cast(e.target, FileReference);
        fileReference.removeEventListener(Event.COMPLETE, onFileLoaded);

        var data:String = fileReference.data.toString();
        var object:Dynamic = haxe.Json.parse(data);
        
        var fileRef:FileReference = new FileReference();
        fileRef.save(Serializer.run(object), "logging.dat");
    }
    
    public function new() {
        // Empty
    }
}

