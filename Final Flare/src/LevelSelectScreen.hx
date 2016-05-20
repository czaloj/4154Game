package;

import game.GameLevel;
import graphics.PositionalAnimator.PAFrame;
import graphics.StaticSprite;
import openfl.display.BitmapData;
import starling.core.Starling;
import starling.display.Image;
import starling.display.Sprite;
import starling.events.Event;
import starling.textures.Texture;
import starling.utils.HAlign;
import starling.utils.VAlign;
import openfl.Assets;
import ui.Button;
import ui.GunVisualizer;
import ui.PanelSprite;

class LevelSelectScreen extends IGameScreen{
    private var textureBackground:Texture;
    private var background:Image;
    private var bmpWeapons:BitmapData;

    private var btnBack:Button;
    private var transitionButtons:Array<PanelSprite>;
    
    private var btnNext:starling.display.Button;
    private var btnPrevious:starling.display.Button;
    
    private var options:Sprite;
    private var btnGuns:Array<Button>;
    private var weaponSelector:StaticSprite;
    private var weaponVis:GunVisualizer;
    
    private var weaponTabIndex:Int;
    private var weaponIndices:Array<Int>;
    
    public function new(sc:ScreenController) {
        super(sc);
    }
    
    override public function build():Void {
        // Load the background image
        textureBackground = Texture.fromBitmapData(Assets.getBitmapData("assets/img/BackgroundLevelSelect.png"), false, false, 1, null, false);
        background = new Image(textureBackground);
        bmpWeapons = Assets.getBitmapData("assets/img/Guns.png");
        
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
        function createButton(x:Float, y:Float, dx:Float, dy:Float, text:String, delay:Float):Button {
            var TRANSITION_BUFFER_PERIOD = 0.4;
            var TRANSITION_TOTAL_TIME = 0.6;
            var b:Button = screenController.uif.createButton(160, 50, text, btf, false);
            var p:PanelSprite = new PanelSprite(b, [delay, TRANSITION_TOTAL_TIME - TRANSITION_BUFFER_PERIOD, TRANSITION_BUFFER_PERIOD - delay], [
                new PAFrame(dx, dy, 0),
                new PAFrame(dx, dy, 0),
                new PAFrame(0, 0, 0),
                new PAFrame(0, 0, 0)
            ]);
            p.x = x;
            p.y = y;
            transitionButtons.push(p);
            return b;
        }
        
        btnBack = createButton(0, Starling.current.stage.stageHeight - 50, 0, 50, "Back", 0.1);
        btnBack.bEvent.add(function():Void {
            screenController.switchToScreen(1);
        });
        
        options = new Sprite();
        btf = {
            tx:60,
            ty:50,
            bold:false,
            color:0xffffffff,
            font:"BitFont",
            hAlign:HAlign.CENTER,
            vAlign:VAlign.CENTER,
            size:50
        };
        btnGuns = [];
        for (i in 0...5) {
            var b:Button = screenController.uif.createButton(60, 50, "W" + (i + 1), btf, false);
            b.bEvent.add(function():Void {
                viewWeaponTab(i);
                weaponSelector.x = b.x - 3;
            });
            b.x = 60 * i;
            options.addChild(b);
        }
        
        // Other elements
        weaponVis = new GunVisualizer(screenController.uif);
        weaponVis.x = 300;
        weaponVis.y = 50;
        options.addChild(weaponVis);
        weaponSelector = screenController.uif.getTile("WeaponSelection");
        weaponSelector.x = -3;
        options.addChild(weaponSelector);
        
        btnPrevious = new starling.display.Button(
            screenController.uif.getSubtexture("LS.Previous.Normal"), "", 
            screenController.uif.getSubtexture("LS.Previous.Hover"),
            screenController.uif.getSubtexture("LS.Previous.Press")
        );
        btnPrevious.addEventListener(Event.TRIGGERED, function(e:Event):Void { cyclePreviousWeapon(); } );
        btnPrevious.y = weaponVis.y + weaponVis.height;
        options.addChild(btnPrevious);
        btnNext = new starling.display.Button(
            screenController.uif.getSubtexture("LS.Next.Normal"), "", 
            screenController.uif.getSubtexture("LS.Next.Hover"),
            screenController.uif.getSubtexture("LS.Next.Press")
        );
        btnNext.addEventListener(Event.TRIGGERED, function(e:Event):Void { cycleNextWeapon(); } );
        btnNext.y = weaponVis.y + weaponVis.height;
        btnNext.x = btnPrevious.x + btnPrevious.width;
        options.addChild(btnNext);
    }
    override public function destroy():Void {
        textureBackground.dispose();
    }

    override public function onEntry(gameTime:GameTime):Void {
        screenController.addChildAt(background, 0);
        for (p in transitionButtons) p.readdTo(screenController);
        screenController.addChild(options);
        
        var pd:PlayerData = screenController.playerData;
        weaponIndices = [0, 1, 2, 3, 0, 4];
        screenController.levelModifiers.characterWeapons = [
            pd.weapons[weaponIndices[0]],
            pd.weapons[weaponIndices[1]],
            pd.weapons[weaponIndices[2]],
            pd.weapons[weaponIndices[3]],
            pd.weapons[weaponIndices[4]], // For testing only
            pd.weapons[weaponIndices[5]]
        ];
        viewWeaponTab(0);
    }
    override public function onExit(gameTime:GameTime):Void {
        screenController.removeChild(background);
        for (p in transitionButtons) p.retract();
        screenController.removeChild(options);
    }
    
    override public function update(gameTime:GameTime):Void {
        // Empty
    }
    override public function draw(gameTime:GameTime):Void {
        // Empty
    }
    
    private function viewWeaponTab(i:Int):Void {
        weaponTabIndex = i;
        weaponVis.view(screenController.levelModifiers.characterWeapons[weaponTabIndex], bmpWeapons);
    }
    private function cycleNextWeapon():Void {
       weaponIndices[weaponTabIndex] = (weaponIndices[weaponTabIndex] + 1) % screenController.playerData.weapons.length;
       screenController.levelModifiers.characterWeapons[weaponTabIndex] = screenController.playerData.weapons[weaponIndices[weaponTabIndex]];
       weaponVis.view(screenController.levelModifiers.characterWeapons[weaponTabIndex], bmpWeapons);
    }
    private function cyclePreviousWeapon():Void {
       weaponIndices[weaponTabIndex] = (weaponIndices[weaponTabIndex] + (screenController.playerData.weapons.length - 1)) % screenController.playerData.weapons.length;
       screenController.levelModifiers.characterWeapons[weaponTabIndex] = screenController.playerData.weapons[weaponIndices[weaponTabIndex]];
       weaponVis.view(screenController.levelModifiers.characterWeapons[weaponTabIndex], bmpWeapons);
    }
}