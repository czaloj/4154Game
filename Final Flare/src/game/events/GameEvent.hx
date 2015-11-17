package game.events;

class GameEvent {
    // Subtypes for casting purposes
    public static inline var TYPE_UNSPECIFIED:Int = 0;
    public static inline var TYPE_SPAWN:Int = 1;
    public static inline var TYPE_FLARE:Int = 2;
    
    @isVar public var type(default, null):Int; // Immutable subtype
    
    public function new(t:Int) {
        type = t;
    }
}
