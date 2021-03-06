package ui;

import graphics.AnimatedSprite;
import graphics.SpriteSheet;
import graphics.StaticSprite;
import graphics.StripRegion;
import graphics.TileRegion;
import starling.display.Sprite;
import openfl.geom.Rectangle;
import starling.textures.SubTexture;
import starling.textures.Texture;
import ui.Button.ButtonTextFormat;


class UISpriteFactory {
    private var sheet:SpriteSheet;

    public function new(t:Texture) {
        sheet = new SpriteSheet(t, [
            // The 9 pieces of a default region
            new TileRegion("Region.Center", 8, 8, 1, 1),
            new TileRegion("Region.Top", 8, 0, 1, 8),
            new TileRegion("Region.Bottom", 8, 9, 1, 8),
            new TileRegion("Region.Left", 0, 8, 8, 1),
            new TileRegion("Region.Right", 9, 8, 8, 1),
            new TileRegion("Region.TopLeft", 0, 0, 8, 8),
            new TileRegion("Region.TopRight", 9, 0, 8, 8),
            new TileRegion("Region.BottomLeft", 0, 9, 8, 8),
            new TileRegion("Region.BottomRight", 9, 9, 8, 8),

            // The 9 pieces of a hovered region
            new TileRegion("Region.Hover.Center", 25, 8, 1, 1),
            new TileRegion("Region.Hover.Top", 25, 0, 1, 8),
            new TileRegion("Region.Hover.Bottom", 25, 9, 1, 8),
            new TileRegion("Region.Hover.Left", 17, 8, 8, 1),
            new TileRegion("Region.Hover.Right", 26, 8, 8, 1),
            new TileRegion("Region.Hover.TopLeft", 17, 0, 8, 8),
            new TileRegion("Region.Hover.TopRight", 26, 0, 8, 8),
            new TileRegion("Region.Hover.BottomLeft", 17, 9, 8, 8),
            new TileRegion("Region.Hover.BottomRight", 26, 9, 8, 8),

            // The 9 pieces of a pressed region
            new TileRegion("Region.Press.Center", 42, 8, 1, 1),
            new TileRegion("Region.Press.Top", 42, 0, 1, 8),
            new TileRegion("Region.Press.Bottom", 42, 9, 1, 8),
            new TileRegion("Region.Press.Left", 34, 8, 8, 1),
            new TileRegion("Region.Press.Right", 43, 8, 8, 1),
            new TileRegion("Region.Press.TopLeft", 34, 0, 8, 8),
            new TileRegion("Region.Press.TopRight", 43, 0, 8, 8),
            new TileRegion("Region.Press.BottomLeft", 34, 9, 8, 8),
            new TileRegion("Region.Press.BottomRight", 43, 9, 8, 8),

            // Scrollbar
            new TileRegion("Scrollbar.Vertical", 61, 10, 8, 11),
            new TileRegion("Scrollbar.Vertical.Top", 51, 0, 10, 10),
            new TileRegion("Scrollbar.Vertical.Center", 51, 10, 10, 1),
            new TileRegion("Scrollbar.Vertical.Bottom", 51, 11, 10, 10),
            new TileRegion("Scrollbar.Horizontal", 69, 10, 11, 8),
            new TileRegion("Scrollbar.Horizontal.Top", 61, 0, 10, 10),
            new TileRegion("Scrollbar.Horizontal.Center", 71, 0, 1, 10),
            new TileRegion("Scrollbar.Horizontal.Bottom", 72, 0, 10, 10),

            // Checkbox
            new TileRegion("Checkbox", 82, 0, 8, 8),
            new TileRegion("Checkbox.Checked", 90, 0, 8, 8),

            // Arrow
            new TileRegion("Arrow", 98, 0, 8, 8),
            
            // Number Input
            new TileRegion("NI.Plus1.Normal", 0, 22, 24, 32),
            new TileRegion("NI.Plus1.Hover", 24, 22, 24, 32),
            new TileRegion("NI.Plus1.Press", 48, 22, 24, 32),
            new TileRegion("NI.Plus2.Normal", 0, 54, 24, 32),
            new TileRegion("NI.Plus2.Hover", 24, 54, 24, 32),
            new TileRegion("NI.Plus2.Press", 48, 54, 24, 32),
            new TileRegion("NI.Plus3.Normal", 0, 86, 24, 32),
            new TileRegion("NI.Plus3.Hover", 24, 86, 24, 32),
            new TileRegion("NI.Plus3.Press", 48, 86, 24, 32),
            new TileRegion("NI.Minus1.Normal", 0, 118, 24, 32),
            new TileRegion("NI.Minus1.Hover", 24, 118, 24, 32),
            new TileRegion("NI.Minus1.Press", 48, 118, 24, 32),
            new TileRegion("NI.Minus2.Normal", 0, 150, 24, 32),
            new TileRegion("NI.Minus2.Hover", 24, 150, 24, 32),
            new TileRegion("NI.Minus2.Press", 48, 150, 24, 32),
            new TileRegion("NI.Minus3.Normal", 0, 182, 24, 32),
            new TileRegion("NI.Minus3.Hover", 24, 182, 24, 32),
            new TileRegion("NI.Minus3.Press", 48, 182, 24, 32),
            new TileRegion("NI.PointText", 0, 214, 50, 96),
            new TileRegion("NI.Top", 50, 214, 494, 36),
            new TileRegion("NI.TopGreen", 171, 229, 370, 18),
            
            // Unique UI pieces
            new TileRegion("Background", 0, 0, 800, 450),

            // Game pieces
            new TileRegion("Health.Background", 794, 0, 230, 30),
            new StripRegion("Health.Overlay",823, 30, 201, 22, 8, 1, 8),
            new TileRegion("Flare", 886, 370, 138, 26),
            new TileRegion("Points", 812, 206, 212, 58),
            new TileRegion("Combo", 840, 264, 184, 26),
            new StripRegion("Combo.Overlay", 898, 290, 126, 10, 8, 1, 8),
            new TileRegion("Reload.Border", 710, 0, 72, 72),
            new TileRegion("Reload.Bullet", 782, 0, 12, 30),
            //new TileRegion("Menu", , , , ),
            //new TileRegion("Time", , , , ),
            //new TileRegion("Character", , , , ) // Healthbars over the character tiles will be Quads
            // TODO: Use real ones
            new TileRegion("EnemyHealthBar.Main", 1023, 1023, 1, 1),
            new TileRegion("EnemyHealthBar.Strip", 1023, 1023, 1, 1),
            
            // The pixel
            new TileRegion("Pixel", 1023, 1023, 1, 1),
            
            // Menu-related stuff
            new TileRegion("WeaponSelection", 0, 500, 68, 56),
            new TileRegion("WeaponVis.Background", 50, 250, 300, 250),
            new TileRegion("WeaponVisualization", 804, 396, 220, 180),
            new TileRegion("LS.Previous.Normal", 72, 22, 46, 22),
            new TileRegion("LS.Previous.Hover", 72, 44, 46, 22),
            new TileRegion("LS.Previous.Press", 72, 66, 46, 22),
            new TileRegion("LS.Next.Normal", 118, 22, 46, 22),
            new TileRegion("LS.Next.Hover", 118, 44, 46, 22),
            new TileRegion("LS.Next.Press", 118, 66, 46, 22),
        ]);
    }

    public function getTile(s:String):StaticSprite {
        return new StaticSprite(sheet, s, false);
    }
    public function getAnimation(s:String, delay:Int = 1):AnimatedSprite {
        return new AnimatedSprite(sheet, s, delay, false);
    }
    public function getSubtexture(s:String):SubTexture {
        var region:TileRegion = sheet.getTile(s);
        return new SubTexture(sheet.texture, region.getSubTextureRegion(), false);
    }

    public function createButtonUp(sx:Float, sy:Float):Sprite {
        var sprite = new Sprite();

        //Create regions from sprite sheet
        sx -= 16;
        sy -= 16;
        addScaledChildSprite("Region.Center", sprite, 8, 8, sx, sy);
        addChildSprite("Region.TopLeft", sprite, 0, 0);
        addScaledChildSprite("Region.Top", sprite, 8, 0, sx, 1);
        addChildSprite("Region.TopRight", sprite, sx + 8, 0);
        addScaledChildSprite("Region.Right", sprite, sx + 8, 8, 1, sy);
        addChildSprite("Region.BottomRight", sprite, 8 + sx, 8 + sy);
        addScaledChildSprite("Region.Bottom", sprite, 8, 8 + sy, sx, 1);
        addChildSprite("Region.BottomLeft", sprite, 0, 8 + sy);
        addScaledChildSprite("Region.Left", sprite, 0, 8, 1, sy);

        return sprite;
    }
    public function createButtonHover(sx:Float, sy:Float):Sprite {
        var sprite = new Sprite();

        //Create regions from sprite sheet
        sx -= 16;
        sy -= 16;
        addScaledChildSprite("Region.Hover.Center", sprite, 8, 8, sx, sy);
        addChildSprite("Region.Hover.TopLeft", sprite, 0, 0);
        addScaledChildSprite("Region.Hover.Top", sprite, 8, 0, sx, 1);
        addChildSprite("Region.Hover.TopRight", sprite, sx + 8, 0);
        addScaledChildSprite("Region.Hover.Right", sprite, sx + 8, 8, 1, sy);
        addChildSprite("Region.Hover.BottomRight", sprite, 8 + sx, 8 + sy);
        addScaledChildSprite("Region.Hover.Bottom", sprite, 8, 8 + sy, sx, 1);
        addChildSprite("Region.Hover.BottomLeft", sprite, 0, 8 + sy);
        addScaledChildSprite("Region.Hover.Left", sprite, 0, 8, 1, sy);

        return sprite;
    }
    public function createButtonPressed(sx:Float, sy:Float):Sprite {
        var sprite = new Sprite();

        //Create regions from sprite sheet
        sx -= 16;
        sy -= 16;
        addScaledChildSprite("Region.Press.Center", sprite, 8, 8, sx, sy);
        addChildSprite("Region.Press.TopLeft", sprite, 0, 0);
        addScaledChildSprite("Region.Press.Top", sprite, 8, 0, sx, 1);
        addChildSprite("Region.Press.TopRight", sprite, sx + 8, 0);
        addScaledChildSprite("Region.Press.Right", sprite, sx + 8, 8, 1, sy);
        addChildSprite("Region.Press.BottomRight", sprite, 8 + sx, 8 + sy);
        addScaledChildSprite("Region.Press.Bottom", sprite, 8, 8 + sy, sx, 1);
        addChildSprite("Region.Press.BottomLeft", sprite, 0, 8 + sy);
        addScaledChildSprite("Region.Press.Left", sprite, 0, 8, 1, sy);

        return sprite;
    }

    public function createButton(sx:Float, sy:Float, text:String, tf:ButtonTextFormat, toggle:Bool):Button {
        var upSprite = createButtonUp(sx, sy);
        var hoverSprite = createButtonHover(sx, sy);
        var downSprite = createButtonPressed(sx, sy);
        var button = new Button(upSprite, hoverSprite, downSprite, text, tf, toggle);
        return button;
    }
    
    public function createCheckbox(sx:Float, sy:Float):Checkbox {
        var upSprite = new Sprite();
        addScaledChildSprite("Checkbox", upSprite, 8, 8, sx, sy);
        var downSprite = new Sprite();
        addScaledChildSprite("Checkbox.Checked", downSprite, 8, 8, sx, sy);
        var checkbox = new Checkbox(upSprite, downSprite);
        return checkbox;
    }

    public function addChildSprite(region:String, parent:Sprite, x:Float, y:Float) {
        addScaledChildSprite(region, parent, x, y, 1, 1);
    }
    
    public function addScaledChildSprite(region:String, parent:Sprite, x:Float, y:Float, sx:Float, sy:Float) {
        var piece:StaticSprite = getTile(region);
        piece.transformationMatrix.scale(sx, sy);
        piece.transformationMatrix.translate(x, y);
        parent.addChild(piece);
    }
}
