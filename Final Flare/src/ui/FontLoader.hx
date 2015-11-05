package ui;
import openfl.Assets;
import starling.text.BitmapFont;
import starling.text.TextField;
import starling.textures.Texture;

class FontLoader{
    public static function loadFonts():Void {
        TextField.registerBitmapFont(loadFont("assets/Font_0.png", "assets/Font.fnt"), "Font");
    }
    private static function loadFont(img:String, fnt:String):BitmapFont {
        var t:Texture = Texture.fromBitmapData(Assets.getBitmapData(img));
        var desc:Xml = Xml.parse(Assets.getText(fnt));
        var bmp = new BitmapFont(t, desc);
        return bmp;
    }
    
    public function new() {
        // Empty
    }
}