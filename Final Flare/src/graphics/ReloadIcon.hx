package graphics;

import starling.display.Sprite;
import ui.UISpriteFactory;

class ReloadIcon extends Sprite {
    public static inline var FADE_IN_TIME:Float = 0.2;
    public static inline var FADE_OUT_TIME:Float = 0.3;
    public static inline var INV_SCALING_FACTOR:Float = 1 / 20.0;
    
    private var timeVisible:Float;
    
    public var isAlive(get, never):Bool;
    
    private var border:StaticSprite;
    private var bullets:Array<StaticSprite>;
    
    private var originalSX:Float;
    private var originalSY:Float;
    private var timeInState:Float;
    private var updateFunction:Float->Void;
    
    public function new(time:Float, sheet:UISpriteFactory) {
        super();
        timeVisible = Math.max(FADE_IN_TIME, time - FADE_IN_TIME) + FADE_OUT_TIME;

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
        
        updateFunction = null;
    }
    
    public function get_isAlive():Bool {
        return timeVisible >= 0;
    }
    
    public function update(dt:Float):Void {
        timeVisible -= dt;
        if (isAlive) {
            if (updateFunction == null) {
                originalSX = scaleX;
                originalSY = scaleY;
                updateFunction = fadeIn;
                timeInState = FADE_IN_TIME;
            }
            updateFunction(dt);
        }
    }
    private function fadeIn(dt:Float):Void {
        timeInState -= dt;
        if (timeInState <= 0) {
            updateFunction = idle;
            timeInState = timeVisible - FADE_OUT_TIME;
            updateFunction(dt);
        }
        else {
            alpha = 1 - (timeInState / FADE_IN_TIME);
            var scaling:Float =  ((1 + INV_SCALING_FACTOR) / (INV_SCALING_FACTOR + alpha));
            scaleX = originalSX * scaling;
            scaleY = originalSY * scaling;
        }
    }
    private function idle(dt:Float):Void {
        timeInState -= dt;
        if (timeInState <= 0) {
            updateFunction = fadeOut;
            timeInState = FADE_OUT_TIME;
            updateFunction(dt);
        }
        else {
            
        }
    }
    private function fadeOut(dt:Float):Void {
        timeInState = Math.max(0, timeInState - dt);
        alpha = timeInState / FADE_OUT_TIME;
        var scaling:Float =  ((1 + INV_SCALING_FACTOR) / (INV_SCALING_FACTOR + alpha));
        scaleX = originalSX * scaling;
        scaleY = originalSY * scaling;
    }
}
