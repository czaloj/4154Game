package;

import flash.display.Sprite;
import flash.Lib;
import game.ColorScheme;
import haxe.remoting.AMFConnection;
import logging.HeatMapBuilder;
import openfl.external.ExternalInterface;
import openfl.geom.Matrix;
import openfl.net.SharedObject;
import starling.core.Starling;
import weapon.PartName;
import game.Statistic;
import weapon.projectile.ProjectileData;
import weapon.WeaponData;
import weapon.WeaponLayer;
import weapon.WeaponPart;
import weapon.WeaponPartType;
import weapon.WeaponProperty;
import weapon.WeaponPropertyType;
import weapon.WeaponPartChild;
import graphics.PositionalAnimator;

class Main extends Sprite {
    private static inline var PROGRAM_TYPE:Int = 0;
    
    private var engine:Starling;

    public function new () {
        super();

        AMFConnection.registerClassAlias("weapon.WeaponData", WeaponData);
        AMFConnection.registerClassAlias("weapon.WeaponLayer", WeaponLayer);
        AMFConnection.registerClassAlias("weapon.WeaponPart", WeaponPart);
        AMFConnection.registerClassAlias("weapon.WeaponProperty", WeaponProperty);
        AMFConnection.registerClassAlias("weapon.WeaponPartChild", WeaponPartChild);
        AMFConnection.registerClassAlias("weapon.ProjectileOrigin", ProjectileOrigin);
        AMFConnection.registerClassAlias("weapon.ProjectileData", ProjectileData);
        AMFConnection.registerClassAlias("weapon.ProjectileChildData", ProjectileChildData);
        AMFConnection.registerClassAlias("weapon.ProjectileExitData", ProjectileExitData);
        AMFConnection.registerClassAlias("graphics.PositionalAnimator", PositionalAnimator);
        AMFConnection.registerClassAlias("KeyframeTimeline", KeyframeTimeline);
        AMFConnection.registerClassAlias("KeyframeTraverseContext", KeyframeTraverseContext);
        AMFConnection.registerClassAlias("PAFrame", PAFrame);
        AMFConnection.registerClassAlias("Pair", Pair);
        AMFConnection.registerClassAlias("openfl.geom.Matrix", Matrix);
        AMFConnection.registerClassAlias("game.ColorScheme", ColorScheme);
        
        switch (PROGRAM_TYPE) {
            case 0:
                engine = new Starling(ScreenController, Lib.current.stage);
                engine.start();
            case 1:
                HeatMapBuilder.run("0.1.1");
        }
    }
}
