package;

import openfl.display.Loader;
import openfl.utils.ByteArray;
import openfl.display.BitmapData;
import openfl.events.Event;
import openfl.geom.Rectangle;
import openfl.net.FileReference;
import openfl.display.PNGEncoderOptions;

class QuickIO {
    public static function loadBitmap(onBMPLoad:BitmapData->Void):Void {
        var fileRef:FileReference = new FileReference();
        fileRef.addEventListener(Event.SELECT, function (e:Event):Void {
            var fileRef:FileReference = cast(e.target, FileReference);
            fileRef.addEventListener(Event.COMPLETE, function (e:Event):Void {
                var fileReference:FileReference = cast(e.target, FileReference);
                var loader = new Loader();
                var bmpData:BitmapData = new BitmapData(1024, 1024);
                loader.contentLoaderInfo.addEventListener(Event.INIT, function(e:Event):Void {
                    bmpData.draw(loader);
                    onBMPLoad(bmpData);
                });
                loader.loadBytes(fileReference.data);
            });
            fileRef.load();
        });
        fileRef.browse();
    }
    public static function saveBitmap(bmp:BitmapData):Void {
        var ba:ByteArray = bmp.encode(new Rectangle(0, 0, bmp.width, bmp.height), new PNGEncoderOptions());
        var fr:FileReference = new FileReference();
        fr.save(ba, "img.png");
    }
    
    public function new() {
        // Empty
    }
}
