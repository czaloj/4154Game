package ui;

import graphics.AnimatedSprite;
import graphics.SpriteSheet;
import graphics.StaticSprite;
import graphics.StripRegion;
import graphics.TileRegion;
import starling.display.DisplayObject;
import starling.display.Sprite;
import starling.textures.Texture;
import starling.display.Button;

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
            
            // Unique UI pieces
            
            
            // Game pieces
            //new StripRegion("Health.BarMain", , , , , , 1, 6),
            //new StripRegion("Health.BarTip", , , , , , 1, 6),
            new TileRegion("Health.Background", 794, 0, 230, 30) //,
            //new TileRegion("Health.Overlay", , , , ),
            //new TileRegion("Flare", , , , ),
            //new TileRegion("Points", , , , ),
            //new TileRegion("Combo", , , , ),
            //new StripRegion("Combo.Animated", , , , , , 1, 20),
            //new StripRegion("Combo.Bar", , , , , , 1, 20),
            //new TileRegion("Menu", , , , ),
            //new TileRegion("Time", , , , ),
            //new TileRegion("Character", , , , ) // Healthbars over the character tiles will be Quads
        ]);
    }
    
    // TODO: Remove these two functions
    public function getTile(s:String):StaticSprite {
        return new StaticSprite(sheet, s, false);
    }
    
    public function createSquareButton():Sprite {
        var button = new Sprite();
        
        //Create regions from sprite sheet
        addChildSprite("Region.Center", button, 8, 8);
        addChildSprite("Region.TopLeft", button, 0, 0);
        addChildSprite("Region.Top", button, 8, 0);
        addChildSprite("Region.TopRight", button, 9, 0);
        addChildSprite("Region.Right", button, 9, 8);
        addChildSprite("Region.BottomRight", button, 9, 9);
        addChildSprite("Region.Bottom", button, 8, 9);
        addChildSprite("Region.BottomLeft", button, 0, 9);
        addChildSprite("Region.Left", button, 0, 8);
        
        return button;        
    }
    
    public function createRectButton():Sprite {
        var button = new Sprite();
        
        //Create regions from sprite sheet
        addScaledChildSprite("Region.Center", button, 9, 9, 20, 2);
        addChildSprite("Region.TopLeft", button, 0, 0);
        addScaledChildSprite("Region.Top", button, 9, 0, 20, 1);
        addChildSprite("Region.TopRight", button, 9, 0);
        addScaledChildSprite("Region.Right", button, 9, 9, 1, 2);
        addChildSprite("Region.BottomRight", button, 9, 9);
        addScaledChildSprite("Region.Bottom", button, 9, 11, 20, 1);
        addChildSprite("Region.BottomLeft", button, 0, 9);
        addScaledChildSprite("Region.Left", button, 0, 11, 1, 2);
        
        return button;
    }
    
    public function addChildSprite(region:String, parent:Sprite, x:Float, y:Float) 
    {
        var piece:StaticSprite = getTile(region);
        piece.x = x;
        piece.y = y;
        parent.addChild(piece);
    }
    
    public function addScaledChildSprite(region:String, parent:Sprite, x:Float, y:Float, sx:Float, sy:Float) {
        var piece:StaticSprite = getTile(region);
        piece.x = x;
        piece.y = y;
        piece.scaleX = sx;
        piece.scaleY = sy;
        parent.addChild(piece);
    }
    public function getAnimation(s:String, delay:Int = 1):AnimatedSprite {
        return new AnimatedSprite(sheet, s, delay, false);
    }
}
