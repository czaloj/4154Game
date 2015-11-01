package;
import game.GameState;
import game.Entity;

// https://gist.github.com/danielcmessias/930e6990d9c6845f2aa5
class Pathfinder {
    private var start:TileNode;
    private var end:TileNode;
    private var walls:Array<Array<Bool>>;
    private var open:List<TileNode>;
    private var closed:List<TileNode>;  
    
    public var g_score:Array<Array<Int>>;
    public var h_score:Array<Array<Int>>;
    public var f_score:Array<Array<Int>>;
    public var highest_f_score:Int;
    
    public function new(entities:Array<game.Entity>, state:game.GameState) {

    }

    private function nodeIs(n1:TileNode, n2:TileNode):Bool {
        return n1.x == n2.x && n1.y == n2.y;
    }
        
    private function contains(list:List<TileNode>, element:TileNode) {
        for (n in list) {
            if (nodeIs(n,element)) {
                return true;
            }
        }
        return false;
    }

    private function pythagoreanDistance(n1:TileNode, n2:TileNode):Int {
        return Std.int(Math.sqrt(Math.pow(n1.x - n2.x, 2) + Math.pow(n1.y - n2.y, 2)));
    }
    
    private function getLowestFScore(list:List<TileNode>):TileNode {
        var lowest_f:Int = -1;
        var lowest_node:TileNode = null;
        for (n in list) {
            var f:Int = -1;
            if (n.parent != null) {
                f = g_score[n.parent.x][n.parent.y] + pythagoreanDistance(n, n.parent) + manhattanDistance(n, end);
            }
            if (f <= lowest_f || lowest_f == -1) {
                lowest_f = f;
                lowest_node = n;
            }
        }
        return lowest_node;
    }

    private function getNeighborNodes(n:TileNode, diagonals:Bool) {
        var neighbours:List<TileNode> = new List<TileNode>();
        var width:Int = walls.length;
        var height:Int = walls[0].length;
        
        if (n.x + 1 < width && !walls[n.x + 1][n.y]) neighbours.add(new TileNode(n.x + 1, n.y, n));
        if (n.x - 1 >= 0 && !walls[n.x - 1][n.y]) neighbours.add(new TileNode(n.x - 1, n.y, n));
        if (n.y + 1 < height && !walls[n.x][n.y + 1]) neighbours.add(new TileNode(n.x, n.y + 1, n));
        if (n.y - 1 >= 0 && !walls[n.x][n.y - 1]) neighbours.add(new TileNode(n.x, n.y - 1, n));
        
        if (!diagonals) return neighbours;
        
        if (n.x + 1 < width && n.y + 1 < height && !walls[n.x + 1][n.y + 1]) neighbours.add(new TileNode(n.x + 1, n.y + 1, n));
        if (n.x - 1 >= 0 && n.y - 1 >= 0 && !walls[n.x - 1][n.y - 1]) neighbours.add(new TileNode(n.x - 1, n.y - 1, n));
        if (n.x + 1 < width && n.y-1 >= 0 && !walls[n.x + 1][n.y - 1]) neighbours.add(new TileNode(n.x + 1, n.y - 1, n));
        if (n.x - 1 >= 0 && n.y + 1 < height && !walls[n.x - 1][n.y + 1]) neighbours.add(new TileNode(n.x - 1, n.y + 1, n));
        
        return neighbours;
    }
    
    private function backtrack(n:TileNode):List<TileNode> {
        if (n.parent != null) {
            var list:List<TileNode> = backtrack(n.parent);
            list.add(n);
            return list;
        } else {
            var list:List<TileNode> = new List<TileNode>();
            list.add(n);
            return list;
        }
    }

    public function manhattanDistance(n1:TileNode, n2:TileNode):Int {
        return Std.int(Math.abs(n1.x - n2.x) + Math.abs(n1.y - n2.y));
    }
    
    public function positionToNode(x:Float, y:Float):TileNode {
        return new TileNode(Std.int(x), Std.int(y));
    }

    public function astar(_start:TileNode, _end:TileNode, _walls:Array<Array<Bool>>, _allow_diagonals:Bool):List<TileNode> {
        walls = _walls;
        start = _start;
        end = _end;
                
        open = new List<TileNode>();
        closed = new List<TileNode>();
        
        g_score = [for (x in 0...walls.length) [for (y in 0...walls[0].length) 0]];
        h_score = [for (x in 0...walls.length) [for (y in 0...walls[0].length) 0]];
        f_score = [for (x in 0...walls.length) [for (y in 0...walls[0].length) 0]];
        highest_f_score = -1;
        
        open.add(start);
        g_score[start.x][start.y] = 0;
        h_score[start.x][start.y] = manhattanDistance(start, end);
        f_score[start.x][start.y] = h_score[start.x][start.y];
        
        // var iterations:Int = 0;
        while (open.length > 0) {
            // iterations++;
            
            var current:TileNode = getLowestFScore(open);
            if (current == null) {
                break;
            }
            if (nodeIs(current, end)) {
                return backtrack(current);
            }
            
            open.remove(current);
            closed.add(current);
            
            var neighbours:List<TileNode> = getNeighborNodes(current, _allow_diagonals);
            for (n in neighbours) {
                if (contains(closed, n)) continue;
                
                var g:Int = g_score[current.x][current.y] + pythagoreanDistance(n, current);
                
                var change_scores:Bool = false;
                if (!contains(open, n)) {
                    open.add(n);
                    change_scores = true;
                } else if (g < g_score[n.x][n.y]) {
                    change_scores = true;
                }
                
                if (change_scores) {
                    g_score[n.x][n.y] = g;
                    h_score[n.x][n.y] = manhattanDistance(n, end);
                    f_score[n.x][n.y] = g_score[n.x][n.y] + h_score[n.x][n.y];
                    if (f_score[n.x][n.y] > highest_f_score) {
                        highest_f_score = f_score[n.x][n.y];
                    }
                }
            }
            
            //if (iterations > 50) break;
        }
        return new List<TileNode>();
    }
    
}