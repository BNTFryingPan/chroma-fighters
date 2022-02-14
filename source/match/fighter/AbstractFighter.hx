package match.fighter;

import PlayerSlot;
import flixel.FlxObject;
import haxe.Constraints.Function;
import match.MatchObject;

typedef MoveResultData = {
   public var ?success:Bool;
   public var ?reason:String;
}

enum MoveResult {
   SUCCESS(data:Null<MoveResultData>);
   REJECTED(data:Null<MoveResultData>);
   NO_SUCH_MOVE;
}

enum FighterAirState {
   GROUNDED; // is literally on the ground
   FULL_CONTROL; // can do any aerial action
   NO_JUMPS; // can do any moves, but cant jump
   PRATFALL; // cant do any actions
   DODGE_PRATFALL; // short pratfall after an air dodge, becomes NO_JUMPS
   SPECIAL_FALL; // like pratfall, but can still do some special moves if the fighter allows it
}

class FighterMoves {
   private final fighter:AbstractFighter;

   private final moves:Map<String, Function> = [];

   public function new(fighter:AbstractFighter) {
      this.fighter = fighter;
   }

   public function performMove(move:String, ...params:Any):Null<MoveResult> {
      if (!this.moves.exists(move))
         return NO_SUCH_MOVE;
      if (params.length > 0)
         return this.moves.get(move)(params);
      return this.moves.get(move)();
   }
}

abstract class AbstractFighter extends FlxObject implements IMatchObjectWithHitbox {
   public var percent:Float;
   public var airState:FighterAirState = GROUNDED;

   public var moveset:FighterMoves;

   public static var recentStaleModifier:Map<Int, Float> = [
      0 => 0.1, 1 => 0.2, 2 => 0.3, 3 => 0.4, 4 => 0.45, 5 => 0.5, 6 => 0.55, 7 => 0.6, 8 => 0.65, 9 => 0.7
   ];

   private var slot:PlayerSlotIdentifier;
   private var recentMoves:Array<String> = ["", "", "", "", "", "", "", "", "", ""];

   public function new(slot:PlayerSlotIdentifier, x:Float, y:Float) {
      super(x, y);
      this.slot = slot;
      this.drag.x = 300;
      this.acceleration.y = 200;

      this.createFighterMoves();
   }

   override public function update(elapsed:Float) {
      super(elapsed);
      this.handleInput(PlayerSlot.getPlayer(this.slot).input);
   }

   abstract public function handleInput(input:GenericInput):Void;

   abstract public function createFighterMoves():Void; // this.moves = new FighterMoves(this);

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
