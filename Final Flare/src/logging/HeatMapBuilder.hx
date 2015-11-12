package logging;

import haxe.ds.ArraySort;
import haxe.Unserializer;
import lime.utils.ByteArray;
import openfl.Assets;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.BlendMode;
import openfl.display.PNGEncoderOptions;
import openfl.geom.ColorTransform;
import openfl.geom.Matrix;
import openfl.geom.Rectangle;
import openfl.Lib;
import openfl.net.FileReference;
import openfl.utils.Object;

class HeatMapBuilder {
    public static function run(version:String):Void {
        var obj:Dynamic = Unserializer.run(Assets.getText("assets/logging/v" + version + ".dat"));

        var blur:BitmapData = Assets.getBitmapData("assets/logging/Blur.png");
        var bmpData:BitmapData = new BitmapData(50 * 32, 25 * 32, true, 0x00000000);
        var actions:Array<Dynamic> = obj.player_actions;
        for (action in actions) {
            if (action.action_id == 1) {
                var splits:Array<String> = action.action_detail.split(",");
                if (splits.length != 3) continue;
                var x:Float = Std.parseFloat(splits[0]);
                var y:Float = Std.parseFloat(splits[1]);
                draw(blur, bmpData, x, y, 1.0, 0.2, 0.05, 0.05);
            }
        }
        var ba:ByteArray = bmpData.encode(new Rectangle(0, 0, bmpData.width, bmpData.height), new PNGEncoderOptions());
        var fr:FileReference = new FileReference();
        fr.save(ba, "img.png");
    }
    
    public static function draw(blur:BitmapData, dest:BitmapData, x:Float, y:Float, r:Float, cR:Float, cG:Float, cB:Float):Void {
        var m:Matrix = new Matrix();
        r *= 32;
        x *= 32;
        y *= 32;
        m.translate(-blur.width / 2, -blur.height / 2);
        m.scale(r / (blur.width / 2), r / (blur.height / 2));
        m.translate(x, y);
        var ct:ColorTransform = new ColorTransform(cR, cG, cB);
        dest.draw(blur, m, ct, BlendMode.ADD, null, true);
    }
    
    public function new() {
        // Empty
    }
}
