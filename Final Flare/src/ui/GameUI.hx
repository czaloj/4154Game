package ui;

import game.GameState;
import graphics.SpriteSheet;
import graphics.StaticSprite;
import starling.display.Sprite;
import starling.text.TextField;

class GameUI extends Sprite {
    private var sheet:UISpriteFactory;
    
    // Internal tracking variables
    private var health:Int;
    private var score:Int;
    private var flareCount:Int;
    private var flareTimer:Float;
    
    // Rendering elements
    private var healthBack:StaticSprite;
    private var healthBar:StaticSprite;
    private var scoreText:TextField;
    private var flareCountText:TextField;
    private var flareTimerText:TextField;
    
    public function new(s:UISpriteFactory) {
        super();
        
        // Health bar
        sheet = s;
        healthBack = sheet.getTile("Health.Background");
        addChild(healthBack);
        healthBar = sheet.getTile("Health.Overlay");
        healthBar.x = 20;
        healthBar.y = 4;
        addChild(healthBar);

        // Text fields
        scoreText = new TextField(20, 36, "----", "BitFont", 36, 0xffffff);
        scoreText.y = -30;
        scoreText.scaleX *= 3;
        scoreText.scaleY *= 3;
        addChild(scoreText);
        flareCountText = new TextField(40, 36, "----", "BitFont", 36, 0xffffff);
        flareCountText.x = 0;
        flareCountText.y = healthBack.height;
        addChild(flareCountText);
        flareTimerText = new TextField(60, 36, "----", "BitFont", 36, 0xffffff);
        flareTimerText.x = 60;
        flareTimerText.y = healthBack.height;
        addChild(flareTimerText);
        
        // Reset values
        health = 1;
        setHealth(0);
        score = 1;
        setScore(0);
        flareCount = 1;
        setFlareCount(0);
        flareTimer = 1.0;
        setFlareTimer(0.0);
    }
    
    public function setHealth(v:Int):Void {
        if (health != v) {
            health = v;
            healthBar.width = 201 * health / 100;
        }
    }
    public function setScore(v:Int):Void {
        if (score != v) {
            score = v;
            scoreText.text = Std.string(score);
            scoreText.x = (ScreenController.SCREEN_WIDTH - scoreText.width) * 0.5;
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
        setHealth(state.player.health);
        setScore(state.score);
    }
}
