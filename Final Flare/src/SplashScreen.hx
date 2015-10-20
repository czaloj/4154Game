package;

class SplashScreen extends IGameScreen {
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
        // Empty
    }
    override public function onExit(gameTime:GameTime):Void {
        // Empty
    }
    
    override public function update(gameTime:GameTime):Void {
        // TODO: Add real switching
        
        // Switch to the main menu
        screenController.switchToScreen(1);
    }
    override public function draw(gameTime:GameTime):Void {
        // Empty
    }
}
