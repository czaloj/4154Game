package ui;
import graphics.StaticSprite;
import openfl.display.BitmapData;
import starling.display.Image;
import starling.display.Sprite;
import starling.text.TextField;
import starling.textures.Texture;
import starling.utils.HAlign;
import starling.utils.VAlign;
import weapon.projectile.ProjectileData;
import weapon.WeaponData;
import weapon.WeaponGenerator;

class GunVisualizer extends Sprite {
    private var data:WeaponData;
    private var dps:Float;
    private var damagePerHit:Float;
    
    private var textName:TextField;
    private var textDamage:TextField;
    private var textDPS:TextField;
    private var textReloadTime:TextField;
    
    private var texWeapon:Texture = null;
    private var weaponImage:Image = null;
    
    public function new(uif:UISpriteFactory) {
        super();
        
        addChild(uif.getTile("WeaponVisualization"));
        
        textName = new TextField(200, 32, "Weapon Name", "BitFont", 32, 0xffffffff, false);
        textName.hAlign = HAlign.CENTER;
        textName.vAlign = VAlign.CENTER;
        textName.autoScale = false;
        textName.x = 10;
        textName.y = 10;
        addChild(textName);
        
        textDamage = new TextField(168, 26, "Damage", "BitFont", 26, 0xffffffff, false);
        textDamage.hAlign = HAlign.RIGHT;
        textDamage.vAlign = VAlign.CENTER;
        textDamage.autoScale = false;
        textDamage.x = 38;
        textDamage.y = 44;
        addChild(textDamage);
        
        textDPS = new TextField(168, 26, "DPS", "BitFont", 26, 0xffffffff, false);
        textDPS.hAlign = HAlign.RIGHT;
        textDPS.vAlign = VAlign.CENTER;
        textDPS.autoScale = false;
        textDPS.x = 38;
        textDPS.y = 72;
        addChild(textDPS);
        
        textReloadTime = new TextField(168, 26, "Reload", "BitFont", 26, 0xffffffff, false);
        textReloadTime.hAlign = HAlign.RIGHT;
        textReloadTime.vAlign = VAlign.CENTER;
        textReloadTime.autoScale = false;
        textReloadTime.x = 38;
        textReloadTime.y = 100;
        addChild(textReloadTime);
        
        var gunBack:StaticSprite = uif.getTile("WeaponVis.Background");
        gunBack.x = -300;
        addChild(gunBack);
    }
    
    public function view(w:WeaponData, bmp:BitmapData):Void {
        data = w;
        
        if (texWeapon != null) {
            texWeapon.dispose();
            texWeapon = null;
            weaponImage.removeFromParent();
            weaponImage = null;
        }
        if (data != null) {
            texWeapon = WeaponGenerator.buildSprite(data, bmp).first;
            weaponImage = new Image(texWeapon);
            weaponImage.height = 240;
            weaponImage.scaleX = weaponImage.scaleY;
            if (weaponImage.width > 286) {
                weaponImage.width = 286;
                weaponImage.scaleY = weaponImage.scaleX;
            }
            weaponImage.y = 125 - weaponImage.height * 0.5;
            weaponImage.x = -150 - weaponImage.width * 0.5;
            addChild(weaponImage);
            
            // Calculate damage quantities
            damagePerHit = 0;
            function getDamage(p:ProjectileData):Float {
                var damage:Float = 0;
                for (c in p.children) damage += getDamage(c.data);
                return damage + p.damage;
            }
            for (po in data.projectileOrigins) {
                damagePerHit += getDamage(po.projectileData);
            }
            dps = damagePerHit / data.getShotTime();
            
            // Update text
            textName.text = data.name;
            textDPS.text = "" + dps;
            textDamage.text = "" + damagePerHit;
            textReloadTime.text = "" + data.reloadTime + " s";
        }
        else {
            textName.text = "NONE";
            textDPS.text = "0";
            textDamage.text = "0";
            textReloadTime.text = "0 s";
        }

    }
}