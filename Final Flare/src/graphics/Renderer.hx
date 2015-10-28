package graphics;

import game.GameState;
import game.ObjectModel;
import game.Projectile;
import game.World;
import haxe.ds.ObjectMap;
import openfl.events.Event;
import openfl.events.KeyboardEvent;
import openfl.events.MouseEvent;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import openfl.Lib;
import openfl.ui.Keyboard;
import starling.core.Starling;
import starling.display.DisplayObject;
import starling.display.Image;
import starling.display.QuadBatch;
import starling.display.Sprite;
import starling.display.Stage;
import starling.textures.RenderTexture;
import starling.textures.Texture;

class Renderer {
    public static inline var PLAYER_WIDTH:Float = 0.9;
    public static inline var PLAYER_HEIGHT:Float = 1.9;
    public static inline var CAMERA_DEBUG_MOVE_SPEED:Float = 5.0;

    private var stageHalfSize:Point = new Point();
    private var hierarchy:RenderHierarchy = new RenderHierarchy();
    private var pack:RenderPack;
    private var stage3D:Stage;
    
    public var sprites:Array<Sprite> = [];
    public var entityTbl:ObjectMap<game.ObjectModel, AnimatedSprite> = new ObjectMap<game.ObjectModel, AnimatedSprite>();
    public var projTbl:ObjectMap<game.Projectile, AnimatedSprite> = new ObjectMap<game.Projectile, AnimatedSprite>();

    // Camera parameters
    public var cameraX(get, set):Float;
    public var cameraY(get, set):Float;
    public var cameraScale(get, set):Float;
    
    // Ratios in x and y for parallax
    private var crX:Float;
    private var crY:Float;
    
    // Tilemap display objects
    private var tilesForeground:QuadBatch;
    private var tilesBackground:QuadBatch;
    
    // Permanence display objects
    private var rtMaskBackground:RenderTexture;
    private var rtMaskImage:Image;
    private var rtBackground:RenderTexture;
    private var rtForeground:RenderTexture;
    
    // This is for debug camera movement
    private var debugViewing:Bool = false;
    private var debugViewMoves:Array<Int> = [ 0, 0, 0, 0, 0, 0 ];

    public function new(stage:Sprite, p:RenderPack, state:game.GameState) {
        pack = p;
        stage3D = stage.stage;

        // Everything will be rendered inside the hierarchy
        stage.stage.color = pack.backgroundColor;
        stage.addChild(hierarchy);
        onWindowResize(null);

        // Default camera
        cameraX = 0;
        cameraY = 0;
        cameraScale = 32;

        // What to do when screen changes size
        Lib.current.stage.addEventListener(Event.RESIZE, onWindowResize);
        Lib.current.stage.addEventListener(MouseEvent.MOUSE_MOVE, function (e:MouseEvent = null):Void {
            crX = e.stageX / ScreenController.SCREEN_WIDTH;
            crY = e.stageY / ScreenController.SCREEN_HEIGHT;
        });
        Lib.current.stage.addEventListener(KeyboardEvent.KEY_DOWN, debugMoveListening);

        load(state);
    }

    public function get_cameraX():Float {
        return -hierarchy.origin.x;
    }
    public function set_cameraX(v:Float):Float {
        hierarchy.origin.x = -v;
        return v;
    }
    public function get_cameraY():Float {
        return -hierarchy.origin.y;
    }
    public function set_cameraY(v:Float):Float {
        hierarchy.origin.y = -v;
        return v;
    }
    public function get_cameraScale():Float {
        return hierarchy.camera.scaleX;
    }
    public function set_cameraScale(v:Float):Float {
        hierarchy.camera.scaleX = v;
        hierarchy.camera.scaleY = -v;
        return v;
    }

    private function onWindowResize(o:Event = null):Void {
        // Recenter the camera
        stageHalfSize.x = Lib.current.stage.stageWidth / 2;
        stageHalfSize.y = Lib.current.stage.stageHeight / 2;
        hierarchy.camera.x = stageHalfSize.x;
        hierarchy.camera.y = stageHalfSize.y;

        // Resize viewport
        stage3D.stageWidth = Lib.current.stage.stageWidth;
        stage3D.stageHeight = Lib.current.stage.stageHeight;
        var viewPortRectangle:Rectangle = new Rectangle(0, 0, stage3D.stageWidth, stage3D.stageHeight);
        Starling.current.viewPort = viewPortRectangle;
    }

    public function onEntityAdded(s:game.GameState, o:game.ObjectModel):Void {
        // Add a corresponding sprite to stage and track this entity
        var enemy = new AnimatedSprite(pack.enemies, "Robot.Run", 3);
        enemy.x = o.position.x - enemy.width * 0.5;
        enemy.y = o.position.y - o.height * 0.5;
        enemy.scaleX /= 32;
        enemy.scaleY /= 32;
        //trace(enemy.x, enemy.y);
        hierarchy.enemy.addChild(enemy);
        entityTbl.set(o,enemy);
        //what sprite gets added? where is this function called? should this be called "addEntitySprite" instead of onEntityAdded?
    }
    public function onEntityRemoved(s:game.GameState, o:game.ObjectModel):Void {
        //idk about this function the implementation i was thinking of was sketchy.
        //i need to figure out the mapping between objectModels and sprites
        hierarchy.enemy.removeChild(entityTbl.get(o));
        entityTbl.remove(o);
        // Remove this entity from the stage
    }

    public function onBulletAdded(s:game.GameState, p:game.Projectile):Void {
        // Add a corresponding sprite to stage and track this entity
        var bullet = new AnimatedSprite(pack.projectiles, "Bullet.Fly", 1);
        bullet.x = p.position.x - bullet.width * 0.5;
        bullet.y = p.position.y - p.height * 0.5;
        bullet.scaleX /= 32;
        bullet.scaleY /= 32;
        //trace(enemy.x, enemy.y);
        hierarchy.projectiles.addChild(bullet);
        projTbl.set(p,bullet);
        //what sprite gets added? where is this function called? should this be called "addEntitySprite" instead of onEntityAdded?
    }
    public function onBulletRemoved(s:game.GameState, p:game.Projectile):Void {
        //idk about this function the implementation i was thinking of was sketchy.
        //i need to figure out the mapping between objectModels and sprites
        hierarchy.projectiles.removeChild(projTbl.get(p));
        projTbl.remove(p);
        // Remove this entity from the stage
    }

    private function load(state:game.GameState):Void {
        // Register listener functions
        state.onEntityAdded.add(onEntityAdded);
        state.onEntityRemoved.add(onEntityRemoved);
        state.onProjectileAdded.add(onBulletAdded);
        state.onProjectileRemoved.add(onBulletRemoved);
        
        var man = new AnimatedSprite(pack.characters, "Man.Run", 3);
        man.x = state.player.position.x - man.width*0.5;
        man.y = state.player.position.y - PLAYER_HEIGHT * 0.5;
        man.scaleX /= 32;
        man.scaleY /= 32;
        hierarchy.player.addChild(man);
        entityTbl.set(state.player, man);
        
        // Generate environment geometry
        tilesForeground = new QuadBatch();
        generateTiles(state, state.foreground, tilesForeground);
        hierarchy.foreground.addChild(tilesForeground);
        tilesBackground = new QuadBatch();
        generateTiles(state, state.background, tilesBackground);
        hierarchy.background.addChild(tilesBackground);
        
        // Add the parallax layers in a sorted order by their width
        pack.parallax.sort(function (t1:Texture, t2:Texture):Int {
            if (t1.width == t2.width) return 0;
            else if (t1.width < t2.width) return -1;
            else return 1;
        });
        for (texture in pack.parallax) {
            hierarchy.parallax.addChild(new ParallaxSprite(texture, state.width * World.TILE_HALF_WIDTH, state.height * World.TILE_HALF_WIDTH, ScreenController.SCREEN_WIDTH, ScreenController.SCREEN_HEIGHT));
        }
        
        // Create the permanence layers
        var permananceWidth:Int = Std.int(state.width * World.TILE_HALF_WIDTH);
        if (permananceWidth > 2048) permananceWidth = 2048;
        var permananceHeight:Int = Std.int(state.height * World.TILE_HALF_WIDTH);
        if (permananceHeight > 2048) permananceHeight = 2048;
        rtMaskBackground = new RenderTexture(permananceWidth, permananceHeight, false);
        rtMaskBackground.clear();
        generateBackgroundClipping();
        rtForeground = new RenderTexture(permananceWidth, permananceHeight, false);
        rtForeground.clear();
        rtBackground = new RenderTexture(permananceWidth, permananceHeight, false);
        rtBackground.clear();
    }

    /** Tilemap generation code **/
    private function getDisconnected(s:GameState, array:Array<Int>, tID:Int, x:Int, y:Int, ts:Int):Int {
        var l:Int = x - ts;
        var r:Int = x + ts;
        var t:Int = y - ts;
        var b:Int = y + ts;
        var n:Int = 0;
        
        for (pos in [
            { x:l, y:t, mask: 0x80 },
            { x:x, y:t, mask: 0xE0 },
            { x:r, y:t, mask: 0x20 },
            { x:r, y:y, mask: 0x38 },
            { x:r, y:b, mask: 0x08 },
            { x:x, y:b, mask: 0x0E },
            { x:l, y:b, mask: 0x02 },
            { x:l, y:y, mask: 0x83 }
        ]) {
            if (pos.x >= 0 && pos.y >= 0 && pos.x < s.width && pos.y < s.height && array[pos.y * s.width + pos.x] != tID) {
                // We are connected to a tile type such as our own
                n |= pos.mask;
            }
        }
        
        return n;
    }
    private function generateTiles(s:GameState, tiles:Array<Int>, tileBatch:QuadBatch):Void {
        // Create foreground
        var i:Int = 0;
        tileBatch.reset();
        var tileImage:Image = new Image(pack.environment.texture);
        for (iy in 0...s.height) {
            var y:Float = (s.height -  (iy + 1)) * World.TILE_HALF_WIDTH;
            for (ix in 0...s.width) {
                var x:Float = ix * World.TILE_HALF_WIDTH;
                var tileID:Int = tiles[i];
                i++;
                if (tileID > 0 && tileID <= 27) {
                    // Position the image
                    tileImage.x = x;
                    tileImage.y = y;
                    
                    // Obtain the correct sprite type
                    var tileName:String = SpriteSheetRegistry.getSheetName(tileID);
                    switch(tileID) {
                        case 1, 2, 3, 6, 7, 8:
                            // Full Connected
                            pack.environment.getConnected(tileName).setToTile(tileImage, getDisconnected(s, tiles, tileID, ix, iy, 2), true);
                            tileImage.width = (tileImage.height = 2 * World.TILE_HALF_WIDTH);
                            tileImage.y -= World.TILE_HALF_WIDTH;
                        case 4, 5, 9:
                            // Half Connected
                            pack.environment.getConnected(tileName).setToTile(tileImage, getDisconnected(s, tiles, tileID, ix, iy, 1), true);
                            tileImage.width = (tileImage.height = World.TILE_HALF_WIDTH);
                        case 14, 15, 16, 17, 18:
                            // Full Single
                            pack.environment.getTile(tileName).setToTile(tileImage, true);
                            tileImage.width = (tileImage.height = 2 * World.TILE_HALF_WIDTH);
                            tileImage.y -= World.TILE_HALF_WIDTH;
                        case 10, 11, 12, 13:
                            // Half Single
                            pack.environment.getTile(tileName).setToTile(tileImage, true);
                            tileImage.width = (tileImage.height = World.TILE_HALF_WIDTH);
                        case 23, 24, 25, 26, 27:
                            // Full Animated
                            
                            tileImage.y -= World.TILE_HALF_WIDTH;
                        case 19, 20, 21, 22:
                            // Half Animated
                            
                    }
                    
                    // Add new image to the foreground
                    tileBatch.addImage(tileImage);
                }
            }
        }
        
        i = 0;
    }
    
    /** Permanence rendering code **/
    private function generateBackgroundClipping():Void {
        // Draw the currently generated background
        rtMaskBackground.drawBundled(function():Void {
            rtMaskBackground.draw(hierarchy.background);
            rtMaskBackground.draw(hierarchy.backgroundDetail);            
        });
        
        rtMaskImage = new Image(rtMaskBackground);
    }
    private function renderPermanence(backgroundObjects:Array<DisplayObject>, foregroundObjects:Array<DisplayObject>):Void {
        rtBackground.drawBundled(function():Void {
            for (obj in backgroundObjects) {
                var curMask:DisplayObject = obj.mask;
                obj.mask = rtMaskImage;
                rtBackground.draw(obj);
                obj.mask = curMask;
            }
        });
        rtForeground.drawBundled(function():Void {
            for (obj in foregroundObjects) {
                rtForeground.draw(obj);
            }
        });
    }
    
    private function debugMoveListening(e:KeyboardEvent = null):Void {
        if (e.keyCode == Keyboard.C) {
            debugViewing = !debugViewing;
            if (debugViewing) {
                for (i in 0...4) debugViewMoves[i] = 0;
                Lib.current.stage.addEventListener(KeyboardEvent.KEY_DOWN, debugMoveCameraKeyDown);
                Lib.current.stage.addEventListener(KeyboardEvent.KEY_UP, debugMoveCameraKeyUp);
            }
            else {
                Lib.current.stage.removeEventListener(KeyboardEvent.KEY_DOWN, debugMoveCameraKeyDown);
                Lib.current.stage.removeEventListener(KeyboardEvent.KEY_UP, debugMoveCameraKeyUp);
            }
        }
    }
    private function debugMoveCameraKeyDown(e:KeyboardEvent = null):Void {
        switch(e.keyCode) {
            case Keyboard.LEFT:
                debugViewMoves[0] = 1;
            case Keyboard.RIGHT:
                debugViewMoves[1] = 1;
            case Keyboard.DOWN:
                debugViewMoves[2] = 1;
            case Keyboard.UP:
                debugViewMoves[3] = 1;
            case Keyboard.X:
                debugViewMoves[4] = 1;
            case Keyboard.Z:
                debugViewMoves[5] = 1;
        }
    }
    private function debugMoveCameraKeyUp(e:KeyboardEvent = null):Void {
        switch(e.keyCode) {
            case Keyboard.LEFT:
                debugViewMoves[0] = 0;
            case Keyboard.RIGHT:
                debugViewMoves[1] = 0;
            case Keyboard.DOWN:
                debugViewMoves[2] = 0;
            case Keyboard.UP:
                debugViewMoves[3] = 0;
            case Keyboard.X:
                debugViewMoves[4] = 0;
            case Keyboard.Z:
                debugViewMoves[5] = 0;
        }
    }

    public function update(s:game.GameState):Void {
        // TODO: Update sprite positions from entities
        for (o in entityTbl.keys()) {
            var sprite:AnimatedSprite = entityTbl.get(o);
            sprite.x = o.position.x - entityTbl.get(o).width * 0.5;
            sprite.y = o.position.y - o.height * 0.5;
            if (o.left && !o.right)  {
                sprite.x += sprite.width;
                sprite.scaleX = -Math.abs(sprite.scaleX);
            } else {
                sprite.scaleX = Math.abs(sprite.scaleX);
            }
        }
        for (p in projTbl.keys()) {
            projTbl.get(p).x = p.body.getPosition().x;
            projTbl.get(p).y = p.body.getPosition().y - projTbl.get(p).height * 0.5;
        }
        var levelWidth:Float = s.width * World.TILE_HALF_WIDTH;
        var levelHeight:Float = s.height * World.TILE_HALF_WIDTH;
        var cameraHalfWidth = stage3D.stageWidth / (2 * cameraScale);
        var cameraHalfHeight = stage3D.stageHeight / (2 * cameraScale);
        if (!debugViewing) {
            // Center camera on player and constrict to level bounds
            cameraX = Math.min((levelWidth) - cameraHalfWidth, Math.max((0) + cameraHalfWidth, s.player.position.x));
            cameraY = Math.min((levelHeight) - cameraHalfHeight, Math.max((0) + cameraHalfHeight, s.player.position.y));
        }
        else {
            // Move the camera according to keyboard input
            cameraX += CAMERA_DEBUG_MOVE_SPEED * ((debugViewMoves[1] - debugViewMoves[0]) / 60);
            cameraY += CAMERA_DEBUG_MOVE_SPEED * ((debugViewMoves[3] - debugViewMoves[2]) / 60);
            cameraScale *= [ 0.95, 1, 1.15 ] [1 + (debugViewMoves[5] - debugViewMoves[4])];
        }

        // Update parallax layers
        crX = (cameraX - cameraHalfWidth) / (levelWidth - 2 * cameraHalfWidth);
        crY = (cameraY - cameraHalfHeight) / (levelHeight - 2 * cameraHalfHeight);
        for (layer in hierarchy.parallax.children) {
            var pLayer:ParallaxSprite = cast (layer, ParallaxSprite);
            pLayer.update(crX, crY);
        }
    }
}
