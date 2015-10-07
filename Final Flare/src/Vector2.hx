package  {
    /**
     * ...
     * @author Cristian Zaloj
     */
    public class Vector2 {
        public var x:Number;
        public var y:Number;
        
        public function Vector2(_x:Number = 0, _y:Number = 0) {
            x = _x;
            y = _y;
        }
        
        public function copy():Vector2 {
            return new Vector2(x, y);
        }
        
        public function round():void {
            x = Math.round(x);
            y = Math.round(y);
        }
        
        public function floor():Vector2i {
            return new Vector2i(Math.floor(x), Math.floor(y));
        }
        
        /* Returns a Vector2i resulting from rounding each coordinate. */
        public function copyAsVec2i():Vector2i {
            return new Vector2i(Math.round(x), Math.round(y));
        }

        public function Set(_x:Number, _y:Number):Vector2 {
            x = _x;
            y = _y;
            return this;
        }
        public function SetV(v:Vector2):Vector2 {
            return Set(v.x, v.y);
        }
        
        public function Add(_x:Number, _y:Number):Vector2 {
            x += _x;
            y += _y;
            return this;
        }
        public function AddD(v:Number):Vector2 {
            return Add(v, v);
        }
        public function AddV(v:Vector2):Vector2 {
            return Add(v.x, v.y);
        }
        
        public function Sub(_x:Number, _y:Number):Vector2 {
            x -= _x;
            y -= _y;
            return this;
        }
        public function SubD(v:Number):Vector2 {
            return Sub(v, v);
        }
        public function SubV(v:Vector2):Vector2 {
            return Sub(v.x, v.y);
        }
        
        public function Mul(_x:Number, _y:Number):Vector2 {
            x *= _x;
            y *= _y;
            return this;
        }
        public function MulD(v:Number):Vector2 {
            return Mul(v, v);
        }
        public function MulV(v:Vector2):Vector2 {
            return Mul(v.x, v.y);
        }
        
        public function Div(_x:Number, _y:Number):Vector2 {
            x /= _x;
            y /= _y;
            return this;
        }
        public function DivD(v:Number):Vector2 {
            return MulD(1.0 / v);
        }
        public function DivV(v:Vector2):Vector2 {
            return Div(v.x, v.y);
        }
        
        public function get lengthSq():Number {
            return x * x + y * y;
        }
        public function get length():Number {
            return Math.sqrt(lengthSq);
        }
        
        public function toString():String {
            return x.toString() + " " + y.toString();
        }
    }
}