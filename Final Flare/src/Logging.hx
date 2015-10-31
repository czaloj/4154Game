extern class Logging {
	function new() : Void;
	function initialize(gameId : UInt, versionId : UInt, debugMode : Bool) : Void;
	function recordABTestValue(abValue : UInt) : UInt;
	function recordEvent(actionId : UInt, ?actionDetail : String) : Void;
	function recordLevelEnd() : Void;
	function recordLevelStart(questId : Float, ?questDetail : String) : Void;
	function recordPageLoad(?userInfo : String) : Void;
	static function getSingleton() : Logging;
}