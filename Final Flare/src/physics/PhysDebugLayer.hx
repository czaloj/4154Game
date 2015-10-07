package physics {
    import flash.display.Sprite;
    import pyrokid.Connector;
    import pyrokid.Constants;
    /**
     * ...
     * @author Cristian Zaloj
     */
    public class PhysDebugLayer extends Sprite {
        public function draw(islands:Array, rects:Array) {
            graphics.clear();
            graphics.lineStyle(0.05);
            
            var tiles:Array = [];
            
            graphics.beginFill(0xff0000, 0.3);
            for each (var i:PhysIsland in islands) {
                for (var ty:int = 0; ty < i.tilesHeight;ty++) {
                    for (var tx:int = 0; tx < i.tilesWidth; tx++) {
                        if (i.tileGrid[ty][tx] == null) continue;
                        
                        tiles.push(new PossibleTile(i, tx, ty));
                        graphics.drawRect(tx + i.globalAnchor.x, ty + i.globalAnchor.y, 1, 1);
                    }
                }
            }
            graphics.endFill();
            graphics.beginFill(0x00ff00, 0.3);
            for each (var r:PhysRectangle in rects) {
                graphics.drawRect(r.rect.NX, r.rect.NY, r.rect.halfSize.x * 2, r.rect.halfSize.y * 2);
            }
            graphics.endFill();
            
            CollisionResolver.cullEdges(tiles);
            graphics.lineStyle(0.15, 0x00ffff);
            for each (var t:PossibleTile in tiles) {
                if (t.collideNX) {
                    graphics.moveTo(t.rect.NX, t.rect.NY);
                    graphics.lineTo(t.rect.NX, t.rect.PY);
                }
                if (t.collidePX) {
                    graphics.moveTo(t.rect.PX, t.rect.NY);
                    graphics.lineTo(t.rect.PX, t.rect.PY);
                }
                if (t.collideNY) {
                    graphics.moveTo(t.rect.NX, t.rect.NY);
                    graphics.lineTo(t.rect.PX, t.rect.NY);
                }
                if (t.collidePY) {
                    graphics.moveTo(t.rect.NX, t.rect.PY);
                    graphics.lineTo(t.rect.PX, t.rect.PY);
                }
            }
            
            scaleX = scaleY = Constants.CELL;
        }
    }

}