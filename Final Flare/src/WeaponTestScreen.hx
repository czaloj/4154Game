package;

import openfl.Assets;
import starling.display.DisplayObject;
import starling.display.Sprite;
import weapon.WeaponData;
import weapon.Weapon;
import weapon.WeaponGenParams;
import weapon.WeaponLayer;
import weapon.WeaponGenerator;


class WeaponTestScreen extends IGameScreen {
    // Weapon Stuff
    private var data:WeaponData;
    private var weapon:Weapon;
    private var weaponSprite:DisplayObject;
    
    public function new(sc:ScreenController) {
        super(sc);
    }
    
    override public function build():Void {
        // Empty
    }
    override public function destroy():Void {
        // Empty
    }
    
    override public function onEntry(gameTime:GameTime):Void {
        var test = new WeaponLayer("Receiver.Conventional", [
            new Pair(0, new WeaponLayer("Barrel.Conventional", [
                new Pair(0, new WeaponLayer("Magazine.Conventional")),
                new Pair(1, new WeaponLayer("Stock.Conventional")),
                new Pair(2, new WeaponLayer("Projectile.Bullet"))
            ])),
            new Pair(1, new WeaponLayer("Grip.Conventional"))
        ]);
        
        var params:WeaponGenParams = new WeaponGenParams();
        params.evolutionPoints = 1000;
        data = WeaponGenerator.generate(params);
        weaponSprite = WeaponGenerator.buildSprite(data, Assets.getBitmapData("assets/img/Guns.png"));
        
        weaponSprite.x = 400;
        weaponSprite.y = 225;
        weaponSprite.scaleX *= 320;
        weaponSprite.scaleY *= -320;
        screenController.addChild(weaponSprite);
    }
    override public function onExit(gameTime:GameTime):Void {
        screenController.removeChild(weaponSprite);
    }
    
    override public function update(gameTime:GameTime):Void {
        // Empty
    }
    override public function draw(gameTime:GameTime):Void {
        // Empty
    }
}