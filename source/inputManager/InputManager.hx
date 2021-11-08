package inputManager;

import PlayerSlot.PlayerSlotIdentifier;
import inputManager.GenericInput.Position;

enum InputType {
	CPUInput;
	KeyboardInput;
	KeyboardAndMouseInput;
	ControllerInput;
}

class InputManager {
	private static var players:Array<GenericInput> = [
		new GenericInput(P1),
		new GenericInput(P2),
		new GenericInput(P3),
		new GenericInput(P4),
		new GenericInput(P5),
		new GenericInput(P6),
		new GenericInput(P7),
		new GenericInput(P8),
	];

	public static function getPlayer(slot:PlayerSlotIdentifier) {
		return InputManager.players[slot];
	}

	public static function setInputType(slot:PlayerSlotIdentifier, type:InputType) {
		if (type == KeyboardInput) {
			players[slot] = new KeyboardHandler(slot);
		} else if (type == KeyboardAndMouseInput) {
			players[slot] = new MouseHandler(slot);
		}
	}

	public static function getCursors():Array<Position> {
		return InputManager.players.map(function(p) {
			return p.getCursorPosition();
		});
	}
}
