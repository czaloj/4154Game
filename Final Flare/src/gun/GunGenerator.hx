package gun;

class GunGenerator {
    // Alpha mask levels for color generation
    public static var ALPHA_LEVEL_TRUE_COLOR:Int = 21;
    public static var ALPHA_LEVEL_TEXTURE:Int = 16;
    public static var ALPHA_LEVEL_PRIMARY:Int = 11;
    public static var ALPHA_LEVEL_SECONDARY:Int = 6;
    public static var ALPHA_LEVEL_TERTIARY:Int = 1;
    public static var ALPHA_LEVEL_INVISIBLE:Int = 0;
    
    public static function generate(params:GunGenParams):GunData {
        var data:GunData = new GunData();

        // TODO: Generate a real gun
        data.name = "Gun";
        data.colorScheme = new GunColorScheme(0xff0000, 0x00ff00, 0x0000ff, 0, 0, 1, 1);
        data.evolutionCost = params.evolutionPoints;
        data.historicalCost = params.historicalPoints;
        data.shadynessCost = params.shadynessPoints;
        
        return data;
    }

    public function new() {
        // Empty
    }
}
