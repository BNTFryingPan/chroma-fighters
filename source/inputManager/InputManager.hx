package inputManager;

import PlayerSlot.PlayerSlotIdentifier;
import flixel.input.gamepad.FlxGamepad;
import flixel.util.typeLimit.OneOfTwo;
import inputManager.GenericInput.Position;
import inputManager.controllers.GenericController;

enum InputType {
	CPUInput;
	KeyboardInput;
	KeyboardAndMouseInput;
	ControllerInput;
}

enum InputDevice {
	Keyboard;
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
		} else if (type == ControllerInput) {
			players[slot] = new GenericController(slot);
		}
	}

	public static function setInputDevice(slot:PlayerSlotIdentifier, inputDevice:OneOfTwo<FlxGamepad, InputDevice>) {
		if (inputDevice == Keyboard) // TODO : probably handle this better
			return;

		if (!Std.isOfType(players[slot], GenericController))
			return;

		var input:FlxGamepad = cast inputDevice;
		var player:GenericController = cast getPlayer(slot);
		player._flixelGamepad = input;
	}

	public static function getCursors():Array<Position> {
		return InputManager.players.map(function(p) {
			return p.getCursorPosition();
		});
	}
}
