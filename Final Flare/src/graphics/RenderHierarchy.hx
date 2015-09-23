package graphics;

import starling.display.Sprite;

class RenderHierarchy extends Sprite {
    // The camera transformation
    public var camera:Sprite = new Sprite();
    
    // Map transformation and layers
    public var origin:Sprite = new Sprite();
    public var background:Sprite = new Sprite();
    public var backgroundDetail:Sprite = new Sprite();
    public var foreground:Sprite = new Sprite();
    public var foregroundDetail:Sprite = new Sprite();
    
    // Entity layers
    public var dead:Sprite = new Sprite();
    public var player:Sprite = new Sprite();
    public var enemy:Sprite = new Sprite();
    public var projectiles:Sprite = new Sprite();
    public var particlesBottom:Sprite = new Sprite();
    public var particlesTop:Sprite = new Sprite();
    
    public function new() {
        super();

        // Transforms
        addChild(camera);
        camera.addChild(origin);

        // Setup layer order (bottom to top)
        origin.addChild(background);
        origin.addChild(backgroundDetail);
        origin.addChild(dead);
        origin.addChild(particlesBottom);
        origin.addChild(foreground);
        origin.addChild(player);
        origin.addChild(enemy);
        origin.addChild(projectiles);
        origin.addChild(particlesTop);
        origin.addChild(foregroundDetail);
    }
}
