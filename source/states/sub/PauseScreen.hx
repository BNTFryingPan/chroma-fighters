package states.sub;

import GameManager.GameState;
import flixel.FlxSubState;

class PauseScreen extends FlxSubState {
   override public function create() {
      super.create();

      this.bgColor = 0x77000000;
   }
}
