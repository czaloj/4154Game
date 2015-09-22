package game;

class Statistic<T> {
    // This value is the unmodified statistic
    @:isVar public var baseValue(default,set):T;
    
    // This value is the true value of the statistic
    public var value(get,null):T;
    
    // Internal use for lazy calculation
    private var calculatedValue:T;
    private var isValueChanged:Bool = true;
    
    public function new(f:T) {
        this.baseValue = f;
    }
    
    public function set_baseValue(v:T):T {
        isValueChanged = (v != this.baseValue);
        return this.baseValue = v;
    }
    public function get_value():T {
        if (isValueChanged) recalculate();
        return calculatedValue;
    }
    
    private function recalculate():Void {
        calculatedValue = this.baseValue;
        isValueChanged = false;
    }
}
