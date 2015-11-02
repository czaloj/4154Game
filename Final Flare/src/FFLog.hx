package;

class FFLog {
    public static inline var LOGGING_GAME_ID:UInt = 121;
    public static inline var TEST_GROUP_COUNT:UInt = 2;

    public static var testID:UInt = -1;
    private static var logger:Logging = null;
    
    public static function init(debug:Bool):Void {
        // Only init once
        if (logger != null) return;
        
        // Must be initialized
        logger = Logging.getSingleton();
        logger.initialize(LOGGING_GAME_ID, ScreenController.VERSION_ID, debug);

        // Get correct test group
        testID = Std.int(Math.random() * TEST_GROUP_COUNT);
        testID = logger.recordABTestValue(testID);

        // Pass page load successful
        var userInfo:String = "USER:" + testID;
        logger.recordPageLoad(userInfo);
    }
    
    public static function recordLevelStart(questId:Float, ?questDetail:String):Void {
        logger.recordLevelStart(questId, questDetail);
    }
	public static function recordEvent(actionId:UInt, ?actionDetail:String):Void {
        logger.recordEvent(actionId, actionDetail);
    }
	public static function recordLevelEnd():Void {
        logger.recordLevelEnd();
    }
}
