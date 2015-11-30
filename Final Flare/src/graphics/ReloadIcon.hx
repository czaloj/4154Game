package graphics;

import starling.display.Sprite;
import ui.UISpriteFactory;

class ReloadIcon extends Sprite {
    public static inline var FADE_IN_TIME:Float = 0.4;
    
    private var timeVisible:Float;
    
    public var isAlive(get, never):Bool;
    
    private var border:StaticSprite;
    private var bullets:Array<StaticSprite>;
    
    public function new(time:Float, sheet:UISpriteFactory) {
        super();
        timeVisible = time;

        // The border around the sprite
        border = sheet.getTile("Reload.Border");
        border.x = border.width * -0.5;
        border.y = border.height * -0.5;
        addChild(border);
        
        // Bullet sprites
        bullets = [
            sheet.getTile("Reload.Bullet"),
            sheet.getTile("Reload.Bullet"),
            sheet.getTile("Reload.Bullet")
        ];
        bullets[0].x = bullets[0].width * -1.7;
        bullets[1].x = bullets[0].width * -0.5;
        bullets[2].x = bullets[0].width * 0.7;
        bullets[0].y = bullets[1].y = bullets[2].y = bullets[0].height * -0.5;
        addChild(bullets[0]);
        addChild(bullets[2]);
        addChild(bullets[1]);
        
        border.color = 0x00d000;
        bullets[0].color = 0xa0a000;
        bullets[1].color = 0xa0a000;
        bullets[2].color = 0xa0a000;
    }
    
    public function get_isAlive():Bool {
        return timeVisible >= 0;
    }
    
    public function update(dt:Float) {
        timeVisible -= dt;
        if (isAlive) {
            
        }
    }
    private function fadeIn(dt:Float) {
        
    }
    private function idle(dt:Float) {
        
    }
    private function fadeOut(dt:Float) {
        
    }
}
