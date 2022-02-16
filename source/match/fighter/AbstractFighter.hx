package match.fighter;

import PlayerSlot;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.math.FlxAngle;
import haxe.Constraints.Function;
import inputManager.GenericInput;
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

   private final moves:Map<String, FighterMove> = [];

   public function new(fighter:AbstractFighter) {
      this.fighter = fighter;
   }

   public function performMove(move:String, ...params:Any):Null<MoveResult> {
      if (!this.moves.exists(move))
         return NO_SUCH_MOVE;
      if (params.length > 0)
         return this.moves.get(move).attempt(params);
      return this.moves.get(move).attempt();
   }
}

abstract class FighterMove {
   public var useCount:Int = 0;

   private final fighter:AbstractFighter;

   public function new(fighter:AbstractFighter) {
      this.fighter = fighter;
   }

   abstract public function attempt(...params:Any):MoveResult;
}

abstract class StatusEffect {
   public var cause(default, null):Null<AbstractFighter>;

   public function new(target:AbstractFighter, ?cause:AbstractFighter) {
      this.cause = cause;
   }

   public function moveSpeedModifier(current:Float):Float {
      return current;
   }

   public function launchVelocityModifier(current:Float):Float {
      return current;
   }

   public function damageDealtModifier(current:Float):Float {
      return current;
   }

   public function damageTakenModifier(current:Float):Float {
      return current;
   }

   public function update(elapsed:Float) {
      // default update does nothing, but not abstract because it doesnt need to do anything
   }

   public function draw() {
      // default draw also does nothing, but its recommended to show some effect
   }
}

abstract class AbstractFighter extends FlxObject implements IMatchObjectWithHitbox {
   public var percent:Float;
   public var airState:FighterAirState = GROUNDED;
   public var hitbox:AbstractHitbox;

   public var iframes:Int = 0;
   public var airJumps:Int = 1;

   public var kills:Int = 0;
   public var deaths:Int = 0;
   public var remainingStocks:Null<Int>; // null is used for time battles if i add those

   public var activeEffects(get, null):Array<StatusEffect> = [];

   public var debugSprite:FlxSprite;

   public var moveset:FighterMoves;

   public static var recentStaleModifier:Map<Int, Float> = [
      0 => 0.1, 1 => 0.2, 2 => 0.3, 3 => 0.4, 4 => 0.45, 5 => 0.5, 6 => 0.55, 7 => 0.6, 8 => 0.65, 9 => 0.7
   ];

   private var slot:PlayerSlotIdentifier;
   private var recentMoves:Array<String> = ["", "", "", "", "", "", "", "", "", ""];

   public function new(slot:PlayerSlotIdentifier, x:Float, y:Float) {
      super(x, y);
      this.width = 10;
      this.height = 10;
      this.slot = slot;
      this.drag.x = 300;
      this.acceleration.y = 200;

      this.debugSprite = new FlxSprite(0, 0);
      this.debugSprite.makeGraphic(10, 10);

      this.createFighterMoves();
   }

   override public function update(elapsed:Float) {
      super.update(elapsed);
      this.debugSprite.setPosition(this.x, this.y);
      // handleInput is called by GameManager when needed
      // this.handleInput(PlayerSlot.getPlayer(this.slot).input);
   }

   abstract public function handleInput(input:GenericInput):Void;

   abstract public function createFighterMoves():Void; // this.moves = new FighterMoves(this);

   public function getPercent():Float {
      return this.percent;
   }

   public function getSlot():Int {
      return cast this.slot;
   }

   public function stale(id:String) {
      this.recentMoves.pop();
      this.recentMoves.unshift(id);
   }

   public function getHeldItem():Null<HoldableItem> {
      return null;
   }

   public function launch(angle:Float = 50, knockback:Float = 1.0) {
      angle = FlxAngle.wrapAngle(angle) * (Math.PI / 180);
      this.velocity.x = (knockback * 100) * Math.cos(angle);
      this.velocity.y = (knockback * 100) * Math.sin(angle);
   }

   override public function draw() {
      super.draw();
      this.debugSprite.draw();
   }

   public function isInBlastzone(stage:Stage):Bool {
      return false;
      // if (stage.blastzone.)
   }

   function get_activeEffects():Array<StatusEffect> {
      return this.activeEffects;
   }
}
