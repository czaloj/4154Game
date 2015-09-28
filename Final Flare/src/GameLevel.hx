package;

import openfl.Lib;

class GameLevel {
    public var foreground: Array<Array<String>>; ///<
    public var background: Array<Array<String>>; ///<
    public var p1: Array<Array<String>>; ///<
    public var p2 Array<Array<String>>; ///<
    public var p3 Array<Array<String>>; ///<
    public var entities:Array<ObjectModel>; ///< 
    
    public function new() {
        foreground = [];
    	background = [];
    	p1 = [];
    	p2 = [];
    	p3 = [];
    	entities = [];
    }

    public function createFromFile(file:String):GameLevel {
    	return new();
    }
}
