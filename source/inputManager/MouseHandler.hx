package inputManager;

import PlayerSlot.PlayerSlotIdentifier;
import flixel.FlxG;
import inputManager.GenericInput;
import inputManager.InputHelper;
import inputManager.InputState;
import inputManager.Position;

class MouseHandler extends KeyboardHandler {
   override public function get_inputType() {
      return "Keyboard + Mouse";
   }

   override public function new(slot:PlayerSlotIdentifier, ?profile:String) {
      super(slot, profile);
   }

   override public function getCursorPosition():Coordinates {
      this.cursorPosition.update(FlxG.mouse.screenX, FlxG.mouse.screenY);
      return super.getCursorPosition();
   }

   override function getConfirm():InputState {
      return InputHelper.getFromFlixel(FlxG.mouse.justPressed, FlxG.mouse.justReleased, FlxG.mouse.pressed);
      /*
         var parentState = super.getConfirm();
         var thisState = InputHelper.getFromFlixel(FlxG.mouse.justPressed, FlxG.mouse.justReleased, FlxG.mouse.pressed);
         if (thisState == parentState) {
             return thisState;
         } else if (InputHelper.justChanged(parentState)) {
             return parentState;
         } else if (InputHelper.justChanged(thisState)) {
             return thisState;
         } else if (InputHelper.isPressed(thisState) || InputHelper.isPressed(parentState)) {
             return PRESSED;
         }
         return NOT_PRESSED; 
       */
   }
}
