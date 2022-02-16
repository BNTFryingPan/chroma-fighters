package match.fighter;

import flixel.math.FlxPoint;
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
   public function createFighterMoves() {
      this.moveset = new MagicFighterMoves(this);
   }

   public function handleInput(input:GenericInput) {
      var stick = input.getStick();

      this.velocity.x = stick.x * 100;

      if ((this.airState == GROUNDED || this.airJumps > 0) && InputHelper.isPressed(input.getJump())) {
         this.velocity.y = -125;
      }

      // todo : fastfall

      if (InputHelper.isPressed(input.getTaunt())) {
         this.moveset.performMove('taunt');
      }
   }

   public function collidesWithPoint(point:FlxPoint):Bool {
      return false;
   }
}
