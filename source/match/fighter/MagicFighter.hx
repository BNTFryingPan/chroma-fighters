package match.fighter;

import flixel.math.FlxPoint;
import flixel.math.FlxPoint;
import match.fighter.AbstractFighter;

class MagicFighterMoves extends FighterMoves {
   public function new(fighter:MagicFighter) {
      super(fighter);
      this.moves.set('taunt', this.taunt);
   }

   public function taunt() {
      Main.log('magic taunt!');
      return SUCCESS;
   }
}

class MagicFighter extends AbstractFighter {
   public function createFighterMoves() {
      this.moveset = new MagicFighterMoves(this);
   }
}
