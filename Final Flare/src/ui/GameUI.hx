package ui;

import game.GameState;
import graphics.SpriteSheet;
import graphics.StaticSprite;
import graphics.AnimatedSprite;
import starling.display.Quad;
import starling.display.Sprite;
import starling.filters.ColorMatrixFilter;
import starling.text.TextField;
import starling.utils.HAlign;
import starling.utils.VAlign;

class GameUI extends Sprite {
    public static inline var REGULAR_TEXT_COLOR:UInt = 0x00e0e0;
    
    private var sheet:UISpriteFactory;
    
    // Internal tracking variables
    private var health:Float;
    private var comboMeter:Float;
    private var comboCount:Int;
    private var score:Int;
    private var flareCount:Int;
    private var flareTimer:Float;
    
    // Rendering elements
    private var healthBack:StaticSprite;
    private var healthBar:AnimatedSprite;
    private var healthBarMask:Quad;
    private var scoreText:TextField;
    private var scoreTextTransform:Sprite;
    private var flareCountText:TextField;
    private var flareTimerText:TextField;
    private var combo:StaticSprite;
    private var comboBar:AnimatedSprite;
    private var comboBarMask:Quad;
    private var comboCountText:TextField;
    private var points:StaticSprite;
    private var flareBack:StaticSprite;
    
    public function new(s:UISpriteFactory) {
        super();
        
        // Health bar
        sheet = s;
        healthBack = sheet.getTile("Health.Background");
        addChild(healthBack);
        flareBack = sheet.getTile("Flare");
        flareBack.y = healthBack.y + healthBack.height;
        addChild(flareBack);
        healthBar = sheet.getAnimation("Health.Overlay", 8);
        healthBar.x = 20;
        healthBar.y = 4;
        healthBarMask = new Quad(201, 22);
        healthBarMask.x = healthBar.x;
        healthBarMask.y = healthBar.y;
        addChild(healthBarMask);
        addChild(healthBar);
        healthBar.mask = healthBarMask;

        // Points
        points = sheet.getTile("Points");
        points.x = ScreenController.SCREEN_WIDTH - points.width;
        points.y = 0;
        addChild(points);
        
        // Combo
        combo = sheet.getTile("Combo");
        combo.x = ScreenController.SCREEN_WIDTH - combo.width;
        combo.y = points.y + points.height;
        addChild(combo);
        comboBar = sheet.getAnimation("Combo.Overlay", 16);
        comboBar.x = combo.x + 54;
        comboBar.y = combo.y + 5;
        comboBarMask = new Quad(comboBar.width, comboBar.height);
        comboBarMask.x = comboBar.x;
        comboBarMask.y = comboBar.y;
        addChild(comboBarMask);
        addChild(comboBar);
        comboBar.mask = comboBarMask;
        
        // Text fields
        scoreTextTransform = new Sprite();
        scoreTextTransform.x = points.x + points.width * 0.5;
        scoreTextTransform.y = points.y + points.height * 0.5;
        addChild(scoreTextTransform);
        scoreText = new TextField(204, 72, "----", "BitFont", 72, 0xffffff);
        scoreText.x = -scoreText.width * 0.5;
        scoreText.y = -48;
        scoreText.color = REGULAR_TEXT_COLOR;
        scoreTextTransform.addChild(scoreText);
        flareCountText = new TextField(23, 36, "----", "BitFont", 36, 0xffffff);
        flareCountText.x = 16;
        flareCountText.y = flareBack.y - 10;
        flareCountText.color = REGULAR_TEXT_COLOR;
        addChild(flareCountText);
        flareTimerText = new TextField(66, 36, "----", "BitFont", 36, 0xffffff);
        flareTimerText.x = 50;
        flareTimerText.y = flareBack.y - 10;
        flareTimerText.color = REGULAR_TEXT_COLOR;
        addChild(flareTimerText);
        comboCountText = new TextField(41, 36, "", "BitFont", 36, 0xffffff);
        comboCountText.hAlign = HAlign.CENTER;
        comboCountText.vAlign = VAlign.CENTER;
        comboCountText.x = combo.x + 2;
        comboCountText.y = combo.y - 10;
        addChild(comboCountText);
        
        // Reset values
        health = 1;
        setHealth(0);
        score = 1;
        setScore(0);
        flareCount = 1;
        setFlareCount(0);
        flareTimer = 1.0;
        setFlareTimer(0.0);
        comboMeter = 1.0;
        setComboMeter(0.5);
    }
    
    public function setHealth(r:Float):Void {
        if (health != r) {
            health = r;
            healthBar.color = Std.int(255 * (1 - r)) << 16 | Std.int(255 * r) << 8 | 102;
            healthBar.x = 20 - (healthBar.width * (1 - r));
        }
    }
    public function setComboMeter(r:Float):Void {
        if (comboMeter != r) {
            comboMeter = r;
            comboBar.color = (Std.int(100 * r) + 155) | 0xcccc00;
            comboBar.x = (combo.x + 54) - (comboBar.width * (1 - r));
        }
    }
    public function setComboCount(v:Int):Void {
        if (comboCount != v) {
            comboCount = v;
            comboCountText.text = Std.string(comboCount);
            var r:Float = Math.min(1, comboCount / 12);
            var g:Float = Math.max(0, (12 - comboCount) / 12);
            comboCountText.color = Std.int(255 * r) << 16 | Std.int(255 * g) << 8 | 0x000060;
            combo.color = Std.int(120 * r) << 16 | Std.int(120 * g) << 8 | 0x000060;
        }
    }
    public function setScore(v:Int):Void {
        if (score != v) {
            score = v;
            scoreText.text = Std.string(score);
        }
    }
    public function setFlareCount(v:Int):Void {
        if (flareCount != v) {
            flareCount = v;
            if (flareCount < 0) { 
                flareCountText.text = "NEG";
            }
            else if (flareCount > 999) {
                flareCountText.text = "INF";
            }
            else {
                flareCountText.text = Std.string(flareCount);
            }
        }
    }
    public function setFlareTimer(v:Float):Void {
        if (flareTimer != v) {
            flareTimer = v;
            if (flareTimer < 0) flareTimer = 0.0;
            
            // Obtain time in minutes and seconds
            var m:Int = Std.int(flareTimer / 60.0);
            if (m > 99) m = 99;
            var s:Int = Std.int(flareTimer % 60.0);
            if (s > 59) s = 59;
            
            // Format to 5 characters
            if (m < 10) {
                if (s < 10) {
                    flareTimerText.text = "0" + Std.string(m) + ":0" + Std.string(s);
                }
                else {
                    flareTimerText.text = "0" + Std.string(m) + ":" + Std.string(s);                    
                }
            }
            else if (s < 10) {
                flareTimerText.text = Std.string(m) + ":0" + Std.string(s);                
            }
            else {
                flareTimerText.text = Std.string(m) + ":" + Std.string(s);                
            }
        }
    }
    
    public function update(state:GameState, dt:Float) {
        setHealth(state.player.health / 100.0);
        setScore(state.score);
        setFlareCount(state.flares);
        setFlareTimer(state.flareCountdown);
        setComboCount(state.comboMultiplier);
        setComboMeter(state.comboPercentComplete);
    }
}
