package weapon;
import openfl.geom.Matrix;
import openfl.utils.IDataInput;
import openfl.utils.IDataOutput;
import openfl.utils.IExternalizable;

class WeaponPartChild implements IExternalizable {
    // Offset from the parent for attachment
    public var offset:Matrix;
    public var y:Int;
    
    // Requirements
    public var isRequired:Bool = false;
    public var requirements:Array<WeaponPart->Bool> = [];

    public function new(offset:Matrix=null, required:Bool=false, r:Array<WeaponPart->Bool> = null) {
        this.offset = (offset == null) ? new Matrix() : offset.clone();
        isRequired = required;
        if (r != null) {
            for (v in r) requirements.push(v);
        }
    }
    
    //public function cloned():WeaponPartChild {
        //var wpc:WeaponPartChild = new WeaponPartChild(offset, isRequired, null);
        //wpc.y = y;
        //return wpc;
    //}
    
    public function writeExternal(output:IDataOutput):Void {
        output.writeFloat(offset.a);
        output.writeFloat(offset.b);
        output.writeFloat(offset.c);
        output.writeFloat(offset.d);
        output.writeFloat(offset.tx);
        output.writeFloat(offset.ty);
        output.writeInt(y);
        output.writeBoolean(isRequired);
    }
    public function readExternal(input:IDataInput):Void {
        var a:Float = input.readFloat();
        var b:Float = input.readFloat();
        var c:Float = input.readFloat();
        var d:Float = input.readFloat();
        var x:Float = input.readFloat();
        var y:Float = input.readFloat();
        offset = new Matrix(a, b, c, d, x, y);
        y = input.readInt();
        isRequired = input.readBoolean();
        requirements = [];
    }
}