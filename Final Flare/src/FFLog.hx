package;

class FFLog {
    public static inline var LOGGING_GAME_ID:UInt = 121;
    public static inline var TEST_GROUP_COUNT:UInt = 2;
    private static inline var LEVEL_INVARIANT_MAX:UInt = 1 << 20;

    private static inline var QUEST_ID_MENU:Float = 1.0;
    private static inline var QUEST_ID_LEVEL:Float = 2.0;
    
    public static var testID:UInt = -1;
    private static var logger:Logging = null;
    private static var levelInvariant:UInt = 0;
    
    public static function init(debug:Bool):Void {
        // Only init once
        if (logger != null) return;
        
        // Must be initialized
        logger = Logging.getSingleton();
        logger.initialize(LOGGING_GAME_ID, ScreenController.VERSION_ID, debug);

        // Get correct test group
        testID = Std.int(Math.random() * TEST_GROUP_COUNT);
        testID = logger.assignABTestValue(testID);
        logger.recordABTestValue();

        // Pass page load successful
        var userInfo:String = "USER:" + testID;
        logger.recordPageLoad(userInfo);
    }

    public static function recordArenaStart(id:Int, difficulty:Int = 0) {
        recordLevelStart((id * 4 + difficulty) + QUEST_ID_LEVEL);
    }
    public static function recordArenaEnd() {
        recordLevelEnd();
    }
    public static function recordMenuStart() {
        recordLevelStart(QUEST_ID_MENU);        
    }
    public static function recordMenuEnd() {
        recordLevelEnd();
    }
    
    private static function recordLevelStart(questId:Float, ?questDetail:String):Void {
        logger.recordLevelStart(questId, questDetail);
        levelInvariant = Std.int(Math.random() * LEVEL_INVARIANT_MAX);
        logger.recordEvent(FFLogEvent.LEVEL_INVARIANT, "" + levelInvariant);
    }
    public static function recordEvent(actionId:UInt, ?actionDetail:String):Void {
        logger.recordEvent(actionId, actionDetail);
    }
    private static function recordLevelEnd():Void {
        logger.recordEvent(FFLogEvent.LEVEL_INVARIANT, "" + levelInvariant);
        logger.recordLevelEnd();
    }
}
