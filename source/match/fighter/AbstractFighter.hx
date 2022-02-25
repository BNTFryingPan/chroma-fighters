package match.fighter;

import PlayerSlot;
import flixel.FlxBasic;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.math.FlxAngle;
import flixel.math.FlxMath;
import haxe.Constraints.Function;
import inputManager.GenericInput;
import inputManager.InputState;
import inputManager.Position;
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
   SPECIAL_FALL; // like pratfall, but can still do some special moves if the fighter allows it
   RESPAWN; // on the respawn platform. is a weird state where your technically not on the ground, but can do some things that normally require being on the ground
}

class FighterMoves {
   private final fighter:AbstractFighter;

   private final moves:Map<String, FighterMove> = [];

   // private function register(move:String, attack:FighterMove) {}

   public function new(fighter:AbstractFighter) {
      this.fighter = fighter;
   }

   public function attempt(move:String, state:InputState, input:GenericInput, ...params:Any):Null<MoveResult> {
      if (!this.moves.exists(move)) {
         trace('NO_SUCH_MOVE ${move}');
         return NO_SUCH_MOVE;
      }
      if (params.length > 0)
         return this.moves.get(move).attempt(state, input, params);
      return this.moves.get(move).attempt(state, input);
   }
}

abstract class FighterMove {
   public var useCount:Int = 0;

   private final fighter:AbstractFighter;

   public function new(fighter:AbstractFighter) {
      this.fighter = fighter;
   }

   abstract public function attempt(state:InputState, input:GenericInput, ...params:Any):MoveResult;
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

enum Facing {
   LEFT;
   RIGHT;
}

interface IFighter extends IMatchObjectWithHitbox {
   public var percent:Float;
   public var airState:FighterAirState;
   public var hitbox:AbstractHitbox;
   public var facing:Facing;

   public var airJumps:Int;
   public var iframes:Float;
   public var hitstunTime:Float;

   public var kills:Int;
   public var deaths:Int;
   public var remainingStocks:Null<Int>; // null is used for time battles if i add those

   public var activeEffects(get, null):Array<StatusEffect>;

   // public var drawChildren:Array<FlxBasic>;
   public var debugSprite:FlxSprite;
   public var moveset:FighterMoves;

   // public static var recentStaleModifier:Map<Int, Float>;
   private var slot:PlayerSlotIdentifier;
   private var recentMoves:Array<String>;

   // abstract public function handleInput(elapsed:Float, input:GenericInput):Void;
   public function handleInput(elapsed:Float, input:GenericInput):Void;

   // abstract public function createFighterMoves():Void; // this.moves = new FighterMoves(this);
   public function createFighterMoves():Void; // this.moves = new FighterMoves(this);

   public function getPercent():Float;

   public function getSlot():PlayerSlotIdentifier;

   public function stale(id:String):Void;

   public function getHeldItem():Null<HoldableItem>;

   public function launch(angle:Float = 50, knockback:Float = 1.0, ?ignorePercent:Bool = false):Void;

   public function die():Void;

   public function isInBlastzone(stage:Stage):Bool;
   public function getDebugString():String;
   public var activeHitboxes:Array<AbstractHitbox>;
   public function createRoundAttackHitbox(offset:Position, radius:Float, damage:Float, ?angle:Float = 45, ?duration:Float = 0.2, ?knockback:Float = 1):Void;
}

abstract class AbstractFighter extends FlxObject implements IFighter {
   public var percent:Float;
   public var airState:FighterAirState = GROUNDED;
   public var hitbox:AbstractHitbox;
   public var facing:Facing = RIGHT;

   public var airJumps:Int = 1;
   public var iframes:Float = 0;
   public var hitstunTime:Float = 0;

   public var kills:Int = 0;
   public var deaths:Int = 0;
   public var remainingStocks:Null<Int>; // null is used for time battles if i add those

   public var activeEffects(get, null):Array<StatusEffect> = [];

   // public var drawChildren:Array<FlxBasic>;
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
      this.drag.x = 400;
      this.acceleration.y = 500;

      this.debugSprite = new FlxSprite(0, 0);

      this.debugSprite.makeGraphic(40, 64, 0x22ffffff);

      this.createFighterMoves();
   }

   override public function update(elapsed:Float) {
      super.update(elapsed);
      this.debugSprite.setPosition(this.x, this.y);

      if (this.hitstunTime > 0)
         this.hitstunTime = Math.max(this.hitstunTime - elapsed, 0);

      if (this.iframes > 0)
         this.iframes = Math.max(this.iframes - elapsed, 0);

      GameManager.collideWithStage(this);

      if (this.isTouching(DOWN)) {
         this.airState = GROUNDED;
      }

      for (box in this.activeHitboxes) {
         if (box.active)
            box.update(elapsed);
      }

      PlayerSlot.getPlayer(this.slot).playerBox.setPercentText('${FlxMath.roundDecimal(this.percent, 1)}%');

      // handleInput is called by GameManager when needed

      // this.handleInput(PlayerSlot.getPlayer(this.slot).input);
   }

   // abstract public function handleInput(elapsed:Float, input:GenericInput):Void;
   public function handleInput(elapsed:Float, input:GenericInput):Void {};

   // abstract public function createFighterMoves():Void; // this.moves = new FighterMoves(this);
   public function createFighterMoves():Void {}; // this.moves = new FighterMoves(this);

   public function getPercent():Float {
      return this.percent;
   }

   public function getSlot():PlayerSlotIdentifier {
      return this.slot;
   }

   public function stale(id:String) {
      this.recentMoves.pop();
      this.recentMoves.unshift(id);
   }

   public function getHeldItem():Null<HoldableItem> {
      return null;
   }

   public function launch(angle:Float = 50, knockback:Float = 1.0, ?ignorePercent = false) {
      angle -= 90;
      this.hitstunTime += knockback * 0.4;
      // angle = FlxAngle.wrapAngle(angle) * (Math.PI / 180);
      angle *= (Math.PI / 180);
      var p = this.percent;
      if (ignorePercent)
         p = 0;
      this.velocity.x = (knockback * 100 * (1 + (p / 100))) * Math.cos(angle);
      this.velocity.y = (knockback * 100 * (1 + (p / 100))) * Math.sin(angle);
   }

   override public function draw() {
      super.draw();
      for (box in this.activeHitboxes) {
         if (box.active)
            box.draw();
      }
      if (this.hitbox != null) {
         this.hitbox.draw();
      }
      this.debugSprite.draw();
   }

   override public function drawDebug() {
      super.drawDebug();
   }

   public function die() {
      this.x = 0;
      this.y = -100;
      this.velocity.x = 0;
      this.velocity.y = 0;
      this.airJumps = 0;
      this.deaths++;
      this.hitstunTime = 0;
      this.iframes = 1.75;
      this.percent = 0;
   }

   public function isInBlastzone(stage:Stage):Bool {
      if (this.y < stage.blastzone.topBlastzone * -1)
         return this.hitstunTime > 0;
      if (this.y > stage.blastzone.bottomBlastzone)
         return true;
      if (Math.abs(this.x) > stage.blastzone.sideBlastzone)
         return true;
      return false;
   }

   function get_activeEffects():Array<StatusEffect> {
      return this.activeEffects;
   }

   public function getDebugString():String {
      return "";
   }

   public var activeHitboxes:Array<AbstractHitbox> = [];

   public function createRoundAttackHitbox(offset:Position, radius:Float, damage:Float, ?angle:Float = 45, ?duration:Float = 0.2, ?knockback:Float = 1) {
      var newHitBox = new CircleHitbox(this.x + (this.width / 2) + (offset.x * (this.facing == LEFT ? 1 : -1)), this.y + offset.y, radius);
      newHitBox.duration = duration;
      newHitBox.damage = damage;
      newHitBox.knockback = knockback;
      newHitBox.angle = angle + (this.facing == LEFT ? 180 : 0);
      newHitBox.owner = this.getSlot();
      this.activeHitboxes.push(newHitBox);
   }
}
