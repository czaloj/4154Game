package  {
    /**
     * ...
     * @author Cristian Zaloj
     */
    public class Vector2i {
        public var x:int;
        public var y:int;
        
        public function Vector2i(_x:int = 0, _y:int = 0) {
            x = _x;
            y = _y;
        }
        
        public function copy():Vector2i {
            return new Vector2i(x, y);
        }
        
        /* Returns an equivalent Vector2. */
        public function copyAsVec2():Vector2 {
            return new Vector2(x, y);
        }

        public function Set(_x:int, _y:int):Vector2i {
            x = _x;
            y = _y;
            return this;
        }
        public function SetV(v:Vector2i):Vector2i {
            return Set(v.x, v.y);
        }
        
        public function Add(_x:int, _y:int):Vector2i {
            x += _x;
            y += _y;
            return this;
        }
        public function AddD(v:int):Vector2i {
            return Add(v, v);
        }
        public function AddV(v:Vector2i):Vector2i {
            return Add(v.x, v.y);
        }
        
        public function Sub(_x:int, _y:int):Vector2i {
            x -= _x;
            y -= _y;
            return this;
        }
        public function SubD(v:int):Vector2i {
            return Sub(v, v);
        }
        public function SubV(v:Vector2i):Vector2i {
            return Sub(v.x, v.y);
        }
        
        public function Mul(_x:int, _y:int):Vector2i {
            x *= _x;
            y *= _y;
            return this;
        }
        public function MulD(v:int):Vector2i {
            return Mul(v, v);
        }
        public function MulV(v:Vector2i):Vector2i {
            return Mul(v.x, v.y);
        }
        
        public function Div(_x:int, _y:int):Vector2i {
            x /= _x;
            y /= _y;
            return this;
        }
        public function DivD(v:int):Vector2i {
            return MulD(1.0 / v);
        }
        public function DivV(v:Vector2i):Vector2i {
            return Div(v.x, v.y);
        }

        public function toString():String {
            return x.toString() + " " + y.toString();
        }
    }
}