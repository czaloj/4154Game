package  {
    import flash.display.DisplayObject;
    import flash.display.MovieClip;
    import flash.display.Sprite;
    import flash.net.SharedObject;
    import flash.text.TextField;
    import flash.utils.Dictionary;
    import physics.PhysBox;
    import ui.LevelsInfo;
    import Vector2;
    import Vector2i;
    import pyrokid.entities.*;
    import pyrokid.*;
    
    import flash.display.*;
    import flash.geom.*;
    import ui.playstates.BasePlayState;
    import pyrokid.tools.HashSet;
    
    public class Utils {
        
        private static var directNeighbors:Array = [
            new Vector2i(0, -1),
            new Vector2i(0, 1),
            new Vector2i(-1, 0),
            new Vector2i(1, 0)
        ];

        /**
         * Converts a coordinate from pixel-space to cell space,
         * truncating as necessary
         * @param real
         * @return
         */
        public static function realToCell (real:Number):Number {
            return Math.floor(real/Constants.CELL);
        }
        
        /**
         * Given a y-coordinate for the cell, this returns the pixel
         * coordinate of the top of the cell. This can also be used to
         * find the left edge of the cell given an x-coordinate
         * @param cell Coordinate
         * @return Pixel-space coordinate
         */
        public static function topOfCell (cell:int):Number {
            return cell * Constants.CELL;
        }
        
        /**
         * Given a y-coordinate for the cell, this returns the pixel
         * coordinate of the bottom of the cell. This can also be used to
         * find the right edge of the cell given an x-coordinate
         * @param cell Coordinate
         * @return Pixel-space coordinate
         */
        public static function bottomOfCell (cell:int):Number {
            return (cell+1) * Constants.CELL;
        }
        
        /**
         * Create A Multidimensional Array
         * @param dimension Integer Array Specifying Size Of Each Dimension
         */
        public static function createMultiArray(dimensions:Array):Array {
            // This Is A Bad Argument
            if (dimensions == null || dimensions.length < 1) return null;
            return createMultiArrayRec(0, dimensions);
        }
        private static function createMultiArrayRec(i:int, dimensions:Array):Array {
            var a:Array = new Array(dimensions[i]);
            if (i + 1 < dimensions.length) {
                i++;
                for (var j:int = 0; j < a.length; j++) {
                    a[j] = createMultiArrayRec(i, dimensions);
                }
            }
            return a;
        }
        
        public static function lerp(a:Number, b:Number, r:Number):Number {
            return a + r * (b - a);
        }
        
        public static function removeAllChildren(obj:Sprite):void {
            if (obj == null) {
                return;
            }
            for (var i:int = obj.numChildren - 1; i >= 0; i--) {
                if (obj.getChildAt(i) is BasePlayState) {
                    BasePlayState(obj.getChildAt(i)).removeAllEventListeners();
                }
                obj.removeChildAt(i);
            }
        }
        
        public static function getIntFromBooleans(bools:Array):int {
            var integer:int = 0;
            for (var i:int = 0; i < bools.length; i++) {
                integer += int(bools[i]) << i;
            }
            return integer;
        }
        
        public static function getBooleansFromInt(integer:int):Array {
            var bools:Array = [];
            for (var i:int = 0; i < 4; i++) {
                bools.push(Boolean((integer >> i) & 1));
            }
            return bools;
        }
        
        public static function sizeOfDict(dict:Object):int {
            var count:int = 0;
            for (var key:* in dict) {
                count++;
            }
            return count;
        }
        
        /** Performs BFS on an array of size height by width, starting at start.
         *  It considers an element in the array a neighbor if it is
         *  adjacent in one of the four cardinal directions and isNeighbor
         *  returns true on that coordinate. processNode is called on each coordinate exactly
         *  once, and it returns true iff the BFS should terminate after that node.
         *  @param isNeighbor function(coor:Vector2i):Boolean
         *  @param processNode function(coor:Vector2i):Boolean */
        public static function BFS(width:int, height:int, start:Vector2i, isNeighbor:Function, processNode:Function):void {
            var queue:Array = [start];
            var visited:HashSet = new HashSet();
            visited.add(start);
            while (queue.length > 0) {
                var coor:Vector2i = queue.shift();
                var finishedSearch:Boolean = processNode(coor);
                if (finishedSearch) {
                    return;
                }
                
                var neighbors:Array = getNeighborCoors(coor.x, coor.y);
                neighbors = neighbors.filter(function(nei) {
                    return inBoundsWH(width, height, nei.x, nei.y) && isNeighbor(nei);
                });
                for each (var neighbor:Vector2i in neighbors) {
                    if (!visited.contains(neighbor)) {
                        queue.push(neighbor);
                        visited.add(neighbor);
                    }
                }
            }
        }
        
        /* Returns a Dictionary mapping ids in the given 2D array to
         * coordinates as Vector2is of cells with that id. Excludes 0 from the mappings. */
        public static function getCellMap(ids:Array):Dictionary {
            var dict:Dictionary = new Dictionary();
            foreach (ids, function(x:int, y:int, id:int):void {
                if (id == 0) {
                    return;
                }
                
                if (dict[id] == undefined) {
                    dict[id] = [];
                }
                dict[id].push(new Vector2i(x, y));
            });
            return dict;
        }
        
        /* Returns the top left corner of the bounding box around
         * the provided set of coordinates. */
        public static function getAnchor(coors:Array):Vector2 {
            var xMin:int = int.MAX_VALUE;
            var yMin:int = int.MAX_VALUE;
            for each (var coor:Vector2i in coors) {
                xMin = Math.min(xMin, coor.x);
                yMin = Math.min(yMin, coor.y);
            }
            return new Vector2(xMin, yMin);
        }
        
        /* Prints a 2D array in a viewer-friendly way, making sure each element in a row
         * is spaced apart by at least spacing.*/
        public static function print2DArr(array:Array, spacing:int = 3, cutoff:Boolean = false):void {
            for each (var row:Array in array) {
                var rowStr:String = "";
                for (var j:int = 0; j < row.length; j++) {
                    var item:String = row[j] != undefined ? row[j].toString() : "NA";
                    var padding = Math.max(spacing - item.length, 0);
                    for (var i:int = 0; i < padding; i++) {
                        item += " ";
                    }
                    if (cutoff && row) {
                        item = item.substring(0, spacing);
                    }
                    item += ",";
                    rowStr += item;
                }
                trace(rowStr);
            }
        }
        
        /* Applies func to each element in the 2D array. func should have
         * the following signature: function(x:int, y:int, element):void */
        public static function foreach(array:Array, func:Function):void {
            for (var y:int = 0; y < getH(array); y++) {
                for (var x:int = 0; x < getW(array); x++) {
                    func(x, y, array[y][x]);
                }
            }
        }
        
        
        /* Returns an array of the neighboring values to (x, y) in the given 2D array. */
        public static function getNeighbors(array:Array, x:int, y:int):Array {
            return filterNull(getNeighborCoors(x, y).map(function(coor:Vector2i) {
                return index(array, coor.x, coor.y);
            }));
        }
        
        /* Returns an array of the neighboring coordinates to (x, y).
         * coors, if provided, is an existing array of coordinates onto
         * which the neighboring coordinates are appended. */
        public static function getNeighborCoors(x:int, y:int, coors:Array = null):Array {
            if (coors == null) {
                coors = [];
            }
            for each (var direction:Vector2i in directNeighbors) {
                coors.push(new Vector2i(x + direction.x, y + direction.y));
            }
            return coors;
        }
        
        /* Returns a new 2D array with dimensions width and height.
         * The height is the first dimension, width the second. */
        public static function newArray(width:int, height:int):Array {
            var array:Array = [];
            for (var y:int = 0; y < height; y++) {
                array.push(new Array(width));
            }
            return array;
        }
        
        public static function newArrayOfSize(array:Array):Array {
            return newArray(getW(array), getH(array));
        }
        
        public static function getW(array:Array):int {
            return array[0].length;
        }
        
        public static function getH(array:Array):int {
            return array.length;
        }
        
        /* Returns true iff (x, y) is a valid index in the 2D array. */
        public static function inBounds(array:Array, x:int, y:int):Boolean {
            return inBoundsWH(getW(array), getH(array), x, y);
        }
        
        /* Returns true iff (x, y) is a valid index in a 2D array of width by height. */
        public static function inBoundsWH(width:int, height:int, x:int, y:int):Boolean {
            return y >= 0 && x >= 0 && y < height && x < width;
        }
        
        /* Returns the item at (x, y) in the 2D array if it exists,
         * or null if (x, y) is out of bounds. */
        public static function index(array:Array, x:int, y:int) {
            if (inBounds(array, x, y)) {
                return array[y][x];
            }
            return null;
        }
        
        /* Returns the same array with all null values filtered out. */
        public static function filterNull(array:Array):Array {
            return array.filter(function(o) { return o != null; });
        }
        
        /* Moves obj by distance in the direction that obj is facing. You can offset the direction
         * rotation by offset degrees */
        public static function moveInDirFacing(obj:DisplayObject, distance:int, offset:Number = 0) {
            obj.x += distance * Math.cos((obj.rotation + offset) * (Math.PI / 180));
            obj.y += distance * Math.sin((obj.rotation + offset) * (Math.PI / 180));
        }
        
        
        public static function getXYMultipliers (direction:int):Vector2i {
            if (direction == Constants.DIR_LEFT) {
                return new Vector2i(-1, 0);
            } else if (direction == Constants.DIR_RIGHT) {
                return new Vector2i(1, 0);
            } else if (direction == Constants.DIR_UP) {
                return new Vector2i(0, -1);
            } else if (direction == Constants.DIR_DOWN) {
                return new Vector2i(0, 1);
            } else {
                return new Vector2i(0, 0);
            }
        }
        
        public static function centerInCell(freeEntity:FreeEntity, cellX:int, cellY:int):void {
            centerInCellVert(freeEntity, cellY);
            centerInCellHoriz(freeEntity, cellX);
        }
        
        public static function centerInCellVert(freeEntity:FreeEntity, cellY:int):void {
            freeEntity.y = (cellY + .5) * Constants.CELL - (freeEntity.entityHeight / 2);
        }
        
        public static function centerInCellHoriz(freeEntity:FreeEntity, cellX:int):void {
            freeEntity.x = (cellX + .5) * Constants.CELL - (freeEntity.entityWidth / 2);
        }
        
        /** given a vector of x,y this returns which
         * cardinal direction it is closest to. */
        public static function getQuadrant(dx:int, dy:int) {
            var a:Boolean = dx > dy;
            var b:Boolean = dx > -dy;
            
            if (a && b) {
                return Constants.DIR_RIGHT;
            } else if (a) {
                return Constants.DIR_UP;
            } else if (b) {
                return Constants.DIR_DOWN;
            } else {
                return Constants.DIR_LEFT;
            }
        }
        
        public static function distance(obj1:DisplayObject, obj2:DisplayObject) {
            var xdis:int = obj2.x - obj1.x;
            var ydis:int = obj2.y - obj1.y;
            return Math.sqrt(xdis * xdis + ydis * ydis);
        }
        
        public static function toMC(obj:Object):MovieClip {
            return obj as MovieClip;
        }
        
        public static function frameCountToTimeDisplay(fc:int):String {
            var seconds:int = fc / 60;
            var minutes:int = seconds / 60;
            seconds = seconds % 60;
            return minutes + ":" + (seconds < 10 ? "0" + seconds : seconds);
        }
        
        // -------------------- Coordinate Conversion Functions --------------------- //
        public static function cellToPixel(cellCoor:int):int {
            return cellCoor * Constants.CELL;
        }
    
        public static function clampI(v:int, min:int, max:int):int { 
            if (v < min) return min;
            else if (v > max) return max;
            else return v;
        }
        public static function clampF(v:Number, min:Number, max:Number):Number { 
            if (v < min) return min;
            else if (v > max) return max;
            else return v;
        }
        
        
        public static function generateMinimap(level:Level) {
            var minimapBitmap:Bitmap = new Bitmap();
            minimapBitmap.bitmapData =  new BitmapData(level.cellWidth * Constants.CELL, level.cellHeight * Constants.CELL);
            minimapBitmap.bitmapData.draw(level);
            return minimapBitmap;
        }
        
        public static function getLevelIcon (levelNum:int) {
            var oldCurrLevel:int = LevelsInfo.currLevel;
            LevelsInfo.currLevel = levelNum;
            var recipe:Object = LevelsInfo.getCurrLevelRecipe(levelNum);
            var level:Level = new Level(recipe);
            LevelsInfo.currLevel = oldCurrLevel;
            return generateMinimap(level);
        }
        
        // ------------------- Shared Object Functions -------------------------------//
        
        public static function loadSavedData():void {
            if (Constants.START_FRESH_GAME) return;
            
            var levelSO:SharedObject = SharedObject.getLocal("pyrokid_levelData_kongregate");
            if (levelSO != undefined) {
                if (levelSO.data.hasOwnProperty("maxUnlockedLevel")) {
                    LevelsInfo.maxUnlockedLevel = levelSO.data.maxUnlockedLevel;
                    //trace(LevelsInfo.maxUnlockedLevel);
                }
                
                //Completed levels and creating dictionary of pages to levels
                if (levelSO.data.hasOwnProperty("completedLevels")) {
                    LevelsInfo.restoreCompletedLevels(levelSO.data.completedLevels);
                    //for (var key:* in levelSO.data.completedLevels) {
                        //trace(key);
                    //}
                    //trace("done loading completed levels /n");
                } else {
                    //trace("does not have completedLevels property");
                    //for (var key:* in LevelsInfo.completedLevels) {
                        //trace(key);
                    //}
                }

                if (levelSO.data.hasOwnProperty("bestLevelCompletionTimes")) {
                    LevelsInfo.bestLevelCompletionTimes = levelSO.data.bestLevelCompletionTimes;
                }
            }
        }
        public static function saveLevelData():void {
            var levelSO:SharedObject = SharedObject.getLocal("pyrokid_levelData_kongregate");
            levelSO.data.maxUnlockedLevel = LevelsInfo.maxUnlockedLevel;
            levelSO.data.completedLevels = LevelsInfo.completedLevels;
            levelSO.data.bestLevelCompletionTimes = LevelsInfo.bestLevelCompletionTimes;
            levelSO.flush();
            //trace("saved data");
            //trace("completedLevels looks like: ");
            //for (var key:* in levelSO.data.completedLevels) {
                //trace(key);
            //}
        }
        
        
        public static function findTextFieldInFlashBTN(btn:DisplayObjectContainer):TextField {
            
            for (var i:int = 0; i<btn.numChildren; i++) {
                var child:DisplayObject = btn.getChildAt(i);
                if (child is TextField) {
                    return child as TextField;
                }
            }
            return null;
        }
    }

}