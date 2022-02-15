package states;

import GameManager;
import flixel.FlxObject;
import match.Stage;
import match.fighter.MagicFighter;

class MatchState extends BaseState {
   public var paused:Bool = false;
   public var stage:Stage;

   override public function create() {
      super.create();

      PlayerSlot.PlayerBox.STATE = PlayerBoxState.IN_GAME;
      GameState.isInMatch = true;
      GameState.shouldDrawCursors = false;

      this.stage = new Stage();
      add(this.stage);

      for (player in PlayerSlot.getPlayerArray(true)) {
         if (!player.fighterSelection.ready)
            continue;

         // TODO : change this lmao
         player.fighter = cast add(new MagicFighter(player.slot, 0, this.stage.mainGround.groundHeight));
      }
   }

   override public function update(elapsed:Float) {
      super.update(elapsed);
      for (player in PlayerSlot.getPlayerArray(true)) {
         if (player.fighter == null)
            continue;

         FlxObject.separate(player.fighter, this.stage);
      }
   }

   override public function stateId():String {
      return 'MatchState';
   }
}
