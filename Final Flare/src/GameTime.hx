package;

import openfl.Lib;

class GameTime {
	public var elapsed:Float; ///< Elapsed time since last frame
	public var total:Float; ///< Total time since beginning of application
	public var frame:Int; ///< A frame counter that continually increases
	
	public function new() {
		elapsed = 0.0;
		total = 0.0;
		frame = 0;
	}
}
