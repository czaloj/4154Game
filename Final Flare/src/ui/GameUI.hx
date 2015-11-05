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
    
    // Rendering elements
    private var healthBack:StaticSprite;
    private var healthBar:StaticSprite;
    private var scoreText:TextField;
    
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

        // Score text
        scoreText = new TextField(200, 40, "0", "Courier New", 36, 0xffffff, true);
        addChild(scoreText);
        scoreText.x = (ScreenController.SCREEN_WIDTH - scoreText.width) * 0.5;
        
        // Reset values
        health = 1;
        setHealth(0);
        score = 1;
        setScore(0);
    }
    
    public function setHealth(v:Int):Int {
        if (health != v) {
            health = v;
            healthBar.width = 201 * health / 100;
        }
        return health;
    }
    public function setScore(v:Int):Int {
        if (score != v) {
            score = v;
            scoreText.text = Std.string(score);
        }
        return score;
    }
    
    public function update(state:GameState, dt:Float) {
        setHealth(state.player.health);
        setScore(state.score);
    }
}
