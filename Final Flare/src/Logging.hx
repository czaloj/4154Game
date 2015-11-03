package;

extern class Logging {
	public function new();
	public function initialize(gameId : UInt, versionId : UInt, debugMode : Bool) : Void;
	public function recordABTestValue(abValue : UInt) : UInt;
	public function recordEvent(actionId : UInt, ?actionDetail : String) : Void;
	public function recordLevelEnd() : Void;
	public function recordLevelStart(questId : Float, ?questDetail : String) : Void;
	public function recordPageLoad(?userInfo : String) : Void;
	static function getSingleton():Logging;
}
