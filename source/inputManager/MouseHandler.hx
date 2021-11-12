package inputManager;

import PlayerSlot.PlayerSlotIdentifier;
import flixel.FlxG;
import inputManager.GenericInput.INPUT_STATE;
import inputManager.GenericInput.InputHelper;
import inputManager.GenericInput.Position;

class MouseHandler extends KeyboardHandler {
	override public function new(slot:PlayerSlotIdentifier) {
		this.inputType = "Keyboard + Mouse";
		super(slot);
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
