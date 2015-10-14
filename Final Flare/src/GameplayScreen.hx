package;

import graphics.Renderer;
import graphics.RenderPack;
import graphics.SpriteSheet;
import graphics.StaticSprite;
import graphics.StripRegion;
import graphics.TileRegion;
import gun.GunGenerator;
import gun.GunGenParams;
import gun.Gun;
import openfl.display.Graphics;
import openfl.Lib;
import openfl.Assets;
import openfl.events.KeyboardEvent;
import openfl.events.Event;
import openfl.ui.Keyboard;
import starling.display.Quad;
import starling.textures.Texture;
import ui.UISpriteFactory;

class GameplayScreen extends IGameScreen {
    private var state:GameState;
    private var gameplayController:GameplayController;
    private var renderer:Renderer;
    public var inputController:InputController;

    public function new(sc: ScreenController) {
        super(sc);
    }

    override function build():Void {
        // Empty
    }
    override function destroy():Void {
        // Empty
    }

    override function onEntry(gameTime:GameTime):Void {
        state = new GameState();
        inputController = new InputController();


        // TODO: Remove this test code
        var pack:RenderPack = new RenderPack();
        //var level = new GameLevel();
        //level.width = 75;
        //level.height = 30;
        //level.playerPt.setTo(0, -150);
        //var spawnerTL = new Spawner();
        //spawnerTL.position.setTo(-400, 150);
        //var spawnerTR = new Spawner();
         //spawnerTR.position.setTo(400, 50);
        //var spawnerC = new Spawner();
         //spawnerC.position.setTo(0, 100);
        //level.spawners = [spawnerTL, spawnerTR, spawnerC];
        //level.foreground = [
        //];
        //level.environmentSprites = "assets/img/Factory.png";
        //level.environmentType = "Simple";
        //level.parallax = [
            //"assets/img/FactoryP1.png",
            //"assets/img/FactoryP2.png",
            //"assets/img/FactoryP3.png",
            //"assets/img/FactoryP4.png"
        //];
        //trace(haxe.Serializer.run(level));
        //TODO: Load Level
        //LevelCreator.createFromLevel(level, state, pack);
        LevelCreator.createPackFromFile("assets/level/valley", pack);
        gameplayController = new GameplayController(state);
        renderer = new Renderer(screenController, pack, state);

        openfl.Lib.current.stage.addEventListener(KeyboardEvent.KEY_DOWN, inputController.keyDown);
        openfl.Lib.current.stage.addEventListener(KeyboardEvent.KEY_UP, inputController.keyUp);

        // TODO: Remove this test code
        var uif:UISpriteFactory = new UISpriteFactory(Texture.fromBitmapData(Assets.getBitmapData("assets/img/UI.png")));
        var hb:StaticSprite = uif.getTile("Health.Background");
        hb.scaleX *= 2;
        hb.scaleY *= 2;
        screenController.addChild(hb);
        var ggp:GunGenParams = new GunGenParams();
        var gunData = GunGenerator.generate(ggp);
        var gun:Gun = new Gun(gunData);

    }
    override function onExit(gameTime:GameTime):Void {
        // Empty
    }

    override function update(gameTime:GameTime):Void {
        // Update input first
        inputController.update(state);

        // Update game logic
        gameplayController.update(state, gameTime);
        if (gameTime.frame%120 ==0) {
           //Spawner.spawn(state, renderer);
        }
    }
    override function draw(gameTime:GameTime):Void {
        renderer.update(state);
    }

    public function handlePlayerCollision():Void
    {
        state.player.velocity.y = 0;
    }

}
