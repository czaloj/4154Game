package;

import graphics.PositionalAnimator.PAFrame;
import graphics.StaticSprite;
import openfl.display.BitmapData;
import openfl.Lib;
import starling.core.Starling;
import starling.display.Image;
import starling.display.Sprite;
import starling.events.Event;
import starling.text.TextField;
import starling.textures.Texture;
import starling.utils.Color;
import starling.utils.HAlign;
import starling.utils.VAlign;
import openfl.Assets;
import ui.Button;
import ui.GunVisualizer;
import ui.NumberInput;
import ui.PanelSprite;
import weapon.WeaponData;
import weapon.WeaponGenerator;
import weapon.WeaponGenParams;

typedef SButton = starling.display.Button;

class ShopScreen extends IGameScreen {
    public static var MAX_POINTS:Int = 20000;
    
    private var textureBackground:Texture;
    private var background:Image;
    
    private var btnBack:Button;
    private var transitionButtons:Array<PanelSprite>;
    
    private var shopSprite:Sprite;
    private var niEvolution:NumberInput;
    private var niHistorical:NumberInput;
    private var niShadyness:NumberInput;
    private var textPointsMax:TextField;
    private var btnPurchase:SButton;
    
    private var bmpWeapons:BitmapData;
    private var weaponVis:GunVisualizer;
    
    public function new(sc:ScreenController) {
        super(sc);
    }
    
    override public function build():Void {
        // Load the background image
        textureBackground = Texture.fromBitmapData(Assets.getBitmapData("assets/img/BackgroundShop.png"), false, false, 1, null, false);
        background = new Image(textureBackground);
        
        // Weapon Bitmap
        bmpWeapons = Assets.getBitmapData("assets/img/Guns.png");
        weaponVis = new GunVisualizer(screenController.uif);
        weaponVis.x = 300;
        
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
        
        // Make number shop input
        shopSprite = new Sprite();
        niEvolution = new NumberInput(screenController.uif, 10, 100, 1000, 0, MAX_POINTS);
        niHistorical = new NumberInput(screenController.uif, 10, 100, 1000, 0, MAX_POINTS);
        niHistorical.y = niEvolution.y + niEvolution.height;
        niShadyness = new NumberInput(screenController.uif, 10, 100, 1000, 0, MAX_POINTS);
        niShadyness.y = niHistorical.y + niHistorical.height;
        var textShopBack:StaticSprite = screenController.uif.getTile("NI.PointText");
        textShopBack.width = 250;
        textShopBack.x = -textShopBack.width;
        var textShopTop:StaticSprite = screenController.uif.getTile("NI.Top");
        textShopTop.x = -textShopBack.width;
        textShopTop.y = -textShopTop.height;
        var textShopPoints:TextField = new TextField(42, 96, "EVO\nHIS\nSHD", "BitFont", 32, 0xffffffff);
        textShopPoints.hAlign = HAlign.RIGHT;
        textShopPoints.x = -60;
        textPointsMax = new TextField(180, 96, "MAX: 0\nMAX: 0\nMAX: 0", "BitFont", 32, 0xffffaf);
        textPointsMax.hAlign = HAlign.LEFT;
        textPointsMax.x = 20 - textShopBack.width;
        var textShop:TextField = new TextField(110, 50, "SHOP", "BitFont", 50, 0xffffffff);
        textShop.hAlign = HAlign.CENTER;
        textShop.vAlign = VAlign.BOTTOM;
        textShop.x = -246;
        textShop.y = -48;
        var niBack:StaticSprite = screenController.uif.getTile("NI.PointText");
        niBack.width = 100;
        niBack.height = 96;
        niBack.x = 72;
        btnPurchase = new SButton(screenController.uif.getSubtexture("NI.TopGreen"), "Confirm Purchase");
        btnPurchase.x = -250 + 121;
        btnPurchase.y = -21;
        btnPurchase.addEventListener(Event.TRIGGERED, onPurchase);
        
        shopSprite.addChild(textShopBack);
        shopSprite.addChild(textShopPoints);
        shopSprite.addChild(textPointsMax);
        shopSprite.addChild(textShopTop);
        shopSprite.addChild(textShop);
        shopSprite.addChild(niBack);
        shopSprite.addChild(niEvolution);
        shopSprite.addChild(niHistorical);
        shopSprite.addChild(niShadyness);
        shopSprite.addChild(btnPurchase);
        shopSprite.x = Starling.current.stage.stageWidth - shopSprite.width + textShopBack.width;
        shopSprite.y = Starling.current.stage.stageHeight - 96;
    }
    override public function destroy():Void {
        textureBackground.dispose();
    }

    override public function onEntry(gameTime:GameTime):Void {
        screenController.addChildAt(background, 0);
        for (p in transitionButtons) p.readdTo(screenController);
        
        resetNumberInputs();
        screenController.addChild(shopSprite);
        screenController.addChild(weaponVis);
    }
    override public function onExit(gameTime:GameTime):Void {
        screenController.removeChild(background);
        for (p in transitionButtons) p.retract();
        screenController.removeChild(shopSprite);
        screenController.removeChild(weaponVis);
    }
    
    override public function update(gameTime:GameTime):Void {
        // Empty
    }
    override public function draw(gameTime:GameTime):Void {
        // Empty
    }
    
    private function resetNumberInputs():Void {
        var pd:PlayerData = screenController.playerData;
        niEvolution.setMax(pd.pointsEvolution > MAX_POINTS ? MAX_POINTS : pd.pointsEvolution);
        niEvolution.value = 100;
        niHistorical.setMax(pd.pointsHistorical > MAX_POINTS ? MAX_POINTS : pd.pointsHistorical);
        niHistorical.value = 0;
        niShadyness.setMax(pd.pointsShadyness > MAX_POINTS ? MAX_POINTS : pd.pointsShadyness);
        niShadyness.value = 0;
        textPointsMax.text = "MAX: " + pd.pointsEvolution + "\nMAX: " + pd.pointsHistorical + "\nMAX: " + pd.pointsShadyness;
    }
    private function onPurchase(e:Event):Void {
        var params:WeaponGenParams = new WeaponGenParams();
        params.evolutionPoints = niEvolution.value;
        params.historicalPoints = niHistorical.value;
        params.shadynessPoints = niShadyness.value;
        
        var wd:WeaponData = WeaponGenerator.generate(params);
        if (wd == null) { 
            // TODO: Pop up no possible weapon
            resetNumberInputs();
            return;
        }
        
        // Update points
        screenController.playerData.weapons.push(wd);
        screenController.playerData.pointsEvolution -= wd.evolutionCost;
        screenController.playerData.pointsHistorical -= wd.historicalCost;
        screenController.playerData.pointsShadyness -= wd.shadynessCost;
        screenController.playerData.save();
        resetNumberInputs();
        
        // Viewer
        weaponVis.view(wd, bmpWeapons);
    }
}