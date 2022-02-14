package states;

import GameManager;
import match.Stage;

class MatchState extends BaseState {
   public var paused:Bool = false;
   public var stage:Stage;

   override public function create() {
      super.create();

      PlayerSlot.PlayerBox.STATE = PlayerBoxState.IN_GAME;
   }
}
