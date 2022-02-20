package match.fighter;

import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import inputManager.GenericInput;
import inputManager.InputHelper;
import inputManager.InputState;
import match.fighter.AbstractFighter;

class MagicFighterMoves extends FighterMoves {
   // private final taunt:MagicFighterTaunt;
   public function new(fighter:MagicFighter) {
      super(fighter);
      this.moves.set('taunt', new MagicFighterTaunt(fighter));
      this.moves.set('special', new MagicFighterSpecial(fighter));
   }
}

class MagicFighterTaunt extends FighterMove {
   public function attempt(state:InputState, ...params:Any):MoveResult {
      if (InputHelper.justChanged(state))
         Main.debugDisplay.notify('magic taunt!');
      if (state == JUST_RELEASED)
         FlxTween.color(this.fighter.debugSprite, 1, FlxColor.PINK, FlxColor.WHITE);
      if (InputHelper.isPressed(state))
         return SUCCESS(null);
      return REJECTED(null);
   }
}

class MagicFighterSpecial extends FighterMove {
   public function attempt(state:InputState, ...params:Any):MoveResult {
      if (state == JUST_PRESSED) {
         this.fighter.launch();
         return SUCCESS(null);
      }
      return REJECTED(null);
   }
}

class MagicFighter extends AbstractFighter {
   private var jumpTime:Float = 0;
   private var maxJumpTime:Float = 0.3;
   private var isJumping:Bool = false;
   private var maxAirJumps:Int = 1;
   var dodgeTimer:Float;
   var dodgeDuration:Int = 3;
   var hasBufferedFastFall:Bool = false;

   public function createFighterMoves() {
      this.moveset = new MagicFighterMoves(this);
   }

   private var lastStickDownValue:String = '0';

   private function clamp(value:Float, ?min:Float, ?max:Float):Float {
      if (min != null && min >= value)
         return min;
      if (max != null && max <= value)
         return max;
      return value;
   }

   public function handleInput(elapsed:Float, input:GenericInput) {
      var stick = input.getStick();
      // this.lastStickDownValue = '${stick.y} ${input.getDown()}';
      // this.lastStickDownValue = input.getDown();
      // trace(elapsed);

      if (this.hitstunTime > 0)
         return;

      // if (input.getDodge())

      if (stick.length > 0) {
         var horizontalGroundModifier = this.airState == GROUNDED ? 1 : 0.4;
         this.velocity.x += stick.x * 4000 * elapsed * horizontalGroundModifier;
         this.velocity.x = FlxMath.bound(this.velocity.x, -200, 200);
      }

      var jumpState = InputHelper.realJumpState(input);
      var jumpPressed = InputHelper.isPressed(jumpState);

      if (this.isJumping && !jumpPressed) {
         this.isJumping = false;
      }

      if (!this.isJumping && (this.airState == GROUNDED || this.airJumps > 0)) {
         this.jumpTime = 0;
         if (this.airState == GROUNDED) {
            this.airJumps = this.maxAirJumps;
            this.hasBufferedFastFall = false;
         }
      }

      if (this.jumpTime >= 0 && jumpPressed) {
         this.isJumping = true;
         this.jumpTime += elapsed;
         if (jumpState == JUST_PRESSED && this.airState != GROUNDED)
            this.airJumps--;
      } else {
         this.jumpTime = -1;
      }

      if (jumpTime > 0 && jumpTime < maxJumpTime) {
         this.velocity.y = -200;
      }

      if (stick.y >= 0.3) {
         if (!this.hasBufferedFastFall && this.velocity.y >= -50 && this.velocity.y <= 250) {
            this.hasBufferedFastFall = true;
         } else if (this.airState == GROUNDED) {
            // crouch
         }
      }

      if (this.velocity.y > 0 && this.hasBufferedFastFall) {
         this.velocity.y = 350;
         this.hasBufferedFastFall = false;
      }

      // Main.debugDisplay.notify('${this.airJumps}/${this.maxAirJumps} ${this.isJumping} ${FlxMath.roundDecimal(this.velocity.y, 1)} ${FlxMath.roundDecimal(this.acceleration.y, 1)}');
      // todo : fastfall
      this.moveset.attempt('taunt', input.getTaunt());
      this.moveset.attempt('special', input.getSpecial());
   }

   public function collidesWithPoint(point:FlxPoint):Bool {
      return false;
   }

   override public function getDebugString():String {
      return
         '${this.airJumps} / ${this.maxAirJumps} [${this.hasBufferedFastFall ? 'F' : 'f'}] ${FlxMath.roundDecimal(this.hitstunTime, 2)} ${FlxMath.roundDecimal(this.iframes, 2)}';
   }
}
