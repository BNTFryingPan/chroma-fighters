package cpuController;

import GameManager.GameState;
import inputManager.GenericInput;
import inputManager.InputState;

class CpuController extends GenericInput {
   private var settings(get, null):CpuSettings;
   private function get_settings():CpuSettings {
      return PlayerSlot.getPlayer(this.slot).cpuSettings;
   }

   override public function get_inputType() {
      return "CPU";
   }

   override public function get_inputEnabled() {
      return true;
   }

   override public function getShortJump() {
      if (!(GameState.isInMatch && this.settings.shouldProcessCpuInput()))
         return NOT_PRESSED;
      var p = PlayerSlot.getPlayer(this.slot);
      if (p == null)
         return NOT_PRESSED;
      if (p.fighter == null)
         return NOT_PRESSED;
      if (p.fighter.airState == GROUNDED && p.fighter.airStateTime >= 0.1)
         return JUST_PRESSED;
      return NOT_PRESSED;
   }
   /* override public function getDown():Float {
      if (GameState.isInMatch)
         return 1;
      return 0;
   }*/
}
