package match.fighter;

import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import inputManager.GenericInput;
import inputManager.InputHelper;
import match.fighter.AbstractFighter;

class MagicFighterMoves extends FighterMoves {
   private final taunt:MagicFighterTaunt;

   public function new(fighter:MagicFighter) {
      super(fighter);
      this.taunt = new MagicFighterTaunt(fighter);
      this.moves.set('taunt', this.taunt);
   }
}

class MagicFighterTaunt extends FighterMove {
   public function attempt(...params:Any):MoveResult {
      Main.debugDisplay.notify('magic taunt!');
      FlxTween.color(this.fighter.debugSprite, 1, FlxColor.PINK, FlxColor.WHITE);
      return SUCCESS(null);
   }
}

class MagicFighter extends AbstractFighter {
   private var jumpTime:Float = 0;
   private var maxJumpTime:Float = 0.3;
   private var isJumping:Bool = false;
   private var maxAirJumps:Int = 1;

   public function createFighterMoves() {
      this.moveset = new MagicFighterMoves(this);
   }

   public function handleInput(elapsed:Float, input:GenericInput) {
      var stick = input.getStick();

      if (stick.length > 0) {
         this.velocity.x += stick.x * 25;
         this.velocity.x = FlxMath.bound(this.velocity.x, -200, 200);
      }

      var jumpPressed = InputHelper.isPressed(input.getJump());

      if (this.isJumping && !jumpPressed) {
         this.isJumping = false;
      }

      if (!this.isJumping && (this.airState == GROUNDED || this.airJumps > 0)) {
         this.jumpTime = 0;
         if (this.airState == GROUNDED)
            this.airJumps = this.maxAirJumps;
      }

      if (this.jumpTime >= 0 && jumpPressed) {
         this.isJumping = true;
         this.jumpTime += elapsed;
         if (input.getJump() == JUST_PRESSED && this.airState != GROUNDED)
            this.airJumps--;
      } else {
         this.jumpTime = -1;
      }

      if (jumpTime > 0 && jumpTime < maxJumpTime) {
         this.velocity.y = -200;
      }

      if (this.velocity.y > 0 && input.getDown() > 0) {
         if (this.airState == GROUNDED) {
            // crouch
         } else {
            this.velocity.y += 10;
         }
      }

      // Main.debugDisplay.notify('${this.airJumps}/${this.maxAirJumps} ${this.isJumping} ${FlxMath.roundDecimal(this.velocity.y, 1)} ${FlxMath.roundDecimal(this.acceleration.y, 1)}');

      // todo : fastfall

      if (InputHelper.isPressed(input.getTaunt())) {
         this.moveset.performMove('taunt');
      }
   }

   public function collidesWithPoint(point:FlxPoint):Bool {
      return false;
   }

   override public function getDebugString():String {
      return '${this.airJumps} / ${this.maxAirJumps}';
   }
}
