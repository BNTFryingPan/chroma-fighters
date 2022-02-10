package match.fighter;

typedef MoveResultData = {
    public var ?success:Bool;
    public var ?reason:String;
}

enum MoveResult {
    SUCCESS(data:Null<MoveResultData>);
    REJECTED(data:Null<MoveResultData>);
    NO_SUCH_MOVE;
}

class FighterMoves {
    private final fighter:AbstractFighter;

    private final moves:Map<String, Function> = [
        
    ];

    public function new(fighter:AbstractFighter) {
        this.fighter = fighter;
    }

    public function performMove(move:String, ?params:Array<Any>):Null<MoveResult> {
        if (!this.moves.exists(move)) return NO_SUCH_MOVE;
        if (params) return this.moves.get(move)(...params);
        return this.moves.get(move)();
    }
}

abstract class AbstractFighter implements IMatchObjectWithHitbox {
    public var percent:Float;
    public var airState:FighterAirState = GROUNDED;

    public var x:Float;
    public var y:Float;

    public var moves:FighterMoves;
    
    public static var recentStaleModifier:Map<Int, Float> = [
        0 => 0.1, 1 => 0.2, 2 => 0.3, 3 => 0.4, 4 => 0.45, 5 => 0.5, 6 => 0.55, 7 => 0.6, 8 => 0.65, 9 => 0.7
    ];

    private var slot:PlayerSlotIdentifier;
    private var recentMoves:Array<String> = ["", "", "", "", "", "", "", "", "", ""];

    public function new(slot:PlayerSlotIdentifier, x:Float, y:Float) {
        this.slot = slot;
        this.x = x;
        this.y = y;

        this.drag.x = 300;
        this.acceleration.y = 200;

        this.createFighterMoves();
    }

    abstract public function createFighterMoves() {
        this.moves = new FighterMoves(this);
    }

    public function getPercent(a:String):Float {
        return this.percent;
    }

    public function getSlot(a:String):Int {
        return cast this.slot;
    }

    public function stale(id:String) {
        this.recentMoves.pop();
        this.recentMoves.unshift(id);
    }

    public function getHeldItem():Null<HoldableItem> {
        return null;
    }

    public function launch(angle:Float = 50, knockback:Float = 1.0) {}
}