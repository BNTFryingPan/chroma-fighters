package inputManager;

import PlayerSlot.PlayerSlotIdentifier;
import flixel.FlxG;
import inputManager.GenericInput;
import inputManager.InputHelper;
import inputManager.InputEnums;
import inputManager.InputTypes;

class MouseHandler extends KeyboardHandler {
    override public function get_inputType() {
        return "Keyboard + Mouse";
    }

    override public function new(slot:PlayerSlotIdentifier, ?profile:String) {
        super(slot, profile);
    }

    override function getCursorPosition():Position {
        return {x: FlxG.mouse.screenX, y: FlxG.mouse.screenY}
    }

    override function updateCursorPos(elapsed:Float) {}

    override function getConfirm():INPUT_STATE {
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
