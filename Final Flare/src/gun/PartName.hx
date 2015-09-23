package gun;

import openfl.Lib;

enum PartNameType {
    NOUN;
    ADJECTIVE;
    ADVERB;
}

class PartName {
    public var string:String;
    public var type:PartNameType;
    
    public function new(v:String, t:PartNameType) {
        string = v;
        type = t;
    }
}
