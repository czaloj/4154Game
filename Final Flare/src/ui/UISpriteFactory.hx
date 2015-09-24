package ui;

import graphics.SpriteSheet;
import graphics.StripRegion;
import graphics.TileRegion;
import starling.textures.Texture;

class UISpriteFactory {
    private var sheet:SpriteSheet;
    
    public function new(t:Texture) {
        sheet = new SpriteSheet(t, [
            // The 9 pieces of a default region
            new TileRegion("Region.Center", , , , ),
            new TileRegion("Region.Top", , , , ),
            new TileRegion("Region.Bottom", , , , ),
            new TileRegion("Region.Left", , , , ),
            new TileRegion("Region.Right", , , , ),
            new TileRegion("Region.TopLeft", , , , ),
            new TileRegion("Region.TopRight", , , , ),
            new TileRegion("Region.BottomLeft", , , , ),
            new TileRegion("Region.BottomRight", , , , ),

            // The 9 pieces of a hovered region
            new TileRegion("Region.Hover.Center", , , , ),
            new TileRegion("Region.Hover.Top", , , , ),
            new TileRegion("Region.Hover.Bottom", , , , ),
            new TileRegion("Region.Hover.Left", , , , ),
            new TileRegion("Region.Hover.Right", , , , ),
            new TileRegion("Region.Hover.TopLeft", , , , ),
            new TileRegion("Region.Hover.TopRight", , , , ),
            new TileRegion("Region.Hover.BottomLeft", , , , ),
            new TileRegion("Region.Hover.BottomRight", , , , ),

            // The 9 pieces of a pressed region
            new TileRegion("Region.Press.Center", , , , ),
            new TileRegion("Region.Press.Top", , , , ),
            new TileRegion("Region.Press.Bottom", , , , ),
            new TileRegion("Region.Press.Left", , , , ),
            new TileRegion("Region.Press.Right", , , , ),
            new TileRegion("Region.Press.TopLeft", , , , ),
            new TileRegion("Region.Press.TopRight", , , , ),
            new TileRegion("Region.Press.BottomLeft", , , , ),
            new TileRegion("Region.Press.BottomRight", , , , ),

            // Scrollbar
            new TileRegion("Scrollbar.Vertical", , , , ),            
            new TileRegion("Scrollbar.Vertical.Top", , , , ),            
            new TileRegion("Scrollbar.Vertical.Center", , , , ),            
            new TileRegion("Scrollbar.Vertical.Bottom", , , , ),            
            new TileRegion("Scrollbar.Horizontal", , , , ),            
            new TileRegion("Scrollbar.Horizontal.Top", , , , ),            
            new TileRegion("Scrollbar.Horizontal.Center", , , , ),            
            new TileRegion("Scrollbar.Horizontal.Bottom", , , , ),            
            
            // Checkbox
            new TileRegion("Checkbox", , , , ),
            new TileRegion("Checkbox.Checked", , , , ),
            
            // Unique UI pieces
            
            
            // Game pieces
            new StripRegion("Health.BarMain", , , , , , 1, 6),
            new StripRegion("Health.BarTip", , , , , , 1, 6),
            new TileRegion("Health.Background", , , , ),
            new TileRegion("Health.Overlay", , , , ),
            new TileRegion("Flare", , , , ),
            new TileRegion("Points", , , , ),
            new TileRegion("Combo", , , , ),
            new StripRegion("Combo.Animated", , , , , , 1, 20),
            new StripRegion("Combo.Bar", , , , , , 1, 20),
            new TileRegion("Menu", , , , ),
            new TileRegion("Time", , , , ),
            new TileRegion("Character", , , , ) // Healthbars over the character tiles will be Quads
        ]);
    }
}
