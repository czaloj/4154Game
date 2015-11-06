package weapon.projectile;

import openfl.geom.Matrix;

class ProjectileChildData {
    public var offset:Matrix;
    public var data:ProjectileData;
    
    public function new() {
        // Empty
    }
}

class ProjectileData {
    public var children:Array<ProjectileChildData> = [];
    
    public function new() {
        // Empty
    }
}
