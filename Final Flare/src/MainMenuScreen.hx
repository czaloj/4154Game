package;

import graphics.PositionalAnimator.PAFrame;
import openfl.Assets;
import starling.display.DisplayObject;
import starling.display.Image;
import starling.textures.Texture;
import starling.utils.HAlign;
import starling.utils.VAlign;
import ui.Button;
import ui.PanelSprite;
import weapon.WeaponData;
import weapon.WeaponGenerator;
import weapon.WeaponGenParams;

class MainMenuScreen extends IGameScreen {
    private var textureBackground:Texture;
    private var background:Image;

    private var btnPlay:Button;
    private var btnTutorial:Button;
    private var btnShop:Button;
    private var btnEditor:Button;
    private var transitionButtons:Array<PanelSprite>;
    
    private var transitioningElements:Array<DisplayObject>;

    public function new(sc:ScreenController) {
        super(sc);
    }
    
    override public function build():Void {
        // Load the background image
        textureBackground = Texture.fromBitmapData(Assets.getBitmapData("assets/img/BackgroundMainMenu.png"), false, false, 1, null, false);
        background = new Image(textureBackground);
        
        // Create the buttons
        var btf:ButtonTextFormat = {
            tx:160,
            ty:50,
            bold:false,
            color:0xffffffff,
            font:"BitFont",
            hAlign:HAlign.CENTER,
            vAlign:VAlign.CENTER,
            size:50
        };
        
        transitionButtons = [];
        function createButton(x:Float, y:Float, text:String, delay:Float):Button {
            var TRANSITION_BUFFER_PERIOD = 0.4;
            var TRANSITION_TOTAL_TIME = 0.6;
            var b:Button = screenController.uif.createButton(160, 50, text, btf, false);
            var p:PanelSprite = new PanelSprite(b, [delay, TRANSITION_TOTAL_TIME - TRANSITION_BUFFER_PERIOD, TRANSITION_BUFFER_PERIOD - delay], [
                new PAFrame(-b.width, 0, 0),
                new PAFrame(-b.width, 0, 0),
                new PAFrame(0, 0, 0),
                new PAFrame(0, 0, 0)
            ]);
            p.x = x;
            p.y = y;
            transitionButtons.push(p);
            return b;
        }
        
        btnPlay = createButton(0, 50, "Play", 0.005);
        btnPlay.bEvent.add(function():Void {
            screenController.switchToScreen(2);
        });
        btnTutorial = createButton(0, 100, "Tutorial", 0.1);
        btnTutorial.bEvent.add(function():Void {
            screenController.loadedLevel = LevelCreator.loadLevelFromFile("assets/level/tutorial.lvl");

            // Create tutorial scenario
            var initialWeapons:Array<WeaponData> = WeaponGenerator.generateInitialWeapons();
            screenController.levelModifiers.characterWeapons = [
                initialWeapons[0],
                initialWeapons[1],
                initialWeapons[2],
                initialWeapons[3],
                initialWeapons[0], // For testing only
                initialWeapons[4]
            ];
            var weaponParams:WeaponGenParams = new WeaponGenParams();
            weaponParams.evolutionPoints = 500;
            weaponParams.shadynessPoints = 0;
            weaponParams.historicalPoints = 0;
            screenController.levelModifiers.enemyWeapons = [WeaponGenerator.generate(weaponParams)];
            weaponParams.evolutionPoints = 1000;
            weaponParams.shadynessPoints = 40;
            screenController.levelModifiers.enemyWeapons.push(WeaponGenerator.generate(weaponParams));
            screenController.levelModifiers.enemyWeapons.push(WeaponGenerator.generate(weaponParams));
            weaponParams.evolutionPoints = 2000;
            weaponParams.shadynessPoints = 100;
            weaponParams.historicalPoints = 80;
            screenController.levelModifiers.enemyWeapons.push(WeaponGenerator.generate(weaponParams));
            screenController.levelModifiers.enemyWeapons.push(WeaponGenerator.generate(weaponParams));
            
            screenController.switchToScreen(3);
        });
        btnShop = createButton(0, 150, "Shop", 0.2);
        btnShop.bEvent.add(function():Void {
            screenController.switchToScreen(4);
        });
        btnEditor = createButton(0, 200, "Editor", 0.3);
        btnEditor.bEvent.add(function():Void {
            screenController.switchToScreen(5);
        });
    }
    override public function destroy():Void {
        textureBackground.dispose();
    }
    
    override public function onEntry(gameTime:GameTime):Void {
        screenController.addChildAt(background, 0);
        for (p in transitionButtons) p.readdTo(screenController);
    }
    override public function onExit(gameTime:GameTime):Void {
        screenController.removeChild(background);
        for (p in transitionButtons) p.retract();
    }
    
    override public function update(gameTime:GameTime):Void {
        // Empty
    }
    override public function draw(gameTime:GameTime):Void {
        // Empty
    }
}