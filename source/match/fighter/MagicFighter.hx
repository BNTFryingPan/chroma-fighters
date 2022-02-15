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
   public function attempt():MoveResult {
      Main.debugDisplay.notify('magic taunt!');
      FlxTween.color(this.fighter.debugSprite, 1, FlxColor.PINK, FlxColor.WHITE);
      return SUCCESS
   }
}

class MagicFighter extends AbstractFighter {
   public function createFighterMoves() {
      this.moveset = new MagicFighterMoves(this);
   }

   public function handleInput(input:GenericInput) {
      var stick = input.getStick();

      this.acceleration.x = stick.x;

      if (InputHelper.isPressed(input.getTaunt())) {
         this.moveset.performMove('taunt');
      }
   }

   public function collidesWithPoint(point:FlxPoint):Bool {
      return false;
   }
}
