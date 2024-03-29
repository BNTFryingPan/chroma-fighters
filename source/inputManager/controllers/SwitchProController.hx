package inputManager.controllers;

import PlayerSlot;
import inputManager.InputState;

class SwitchProController extends GenericController {
   override public function get_inputType() {
      return "Controller (Switch Pro Controller)";
   }

   public function new(slot:PlayerSlotIdentifier, ?profile:String) {
      super(slot, profile);
   }

   public override function getButtonState(button:GenericButton):InputState {
      return switch (button) {
         case FACE_A:
            this.getFromFlixelGamepadButton(B);
         case FACE_B:
            this.getFromFlixelGamepadButton(A);
         case FACE_X:
            this.getFromFlixelGamepadButton(Y);
         case FACE_Y:
            this.getFromFlixelGamepadButton(X);
         default:
            super.getButtonState(button);
      }
   }
}
