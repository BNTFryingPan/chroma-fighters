package states;

import CustomButton;
import PlayerSlot.PlayerSlotIdentifier;
import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import inputManager.InputManager;
import inputManager.KeyboardHandler;

class PlayState extends FlxState {
	override public function create() {
		super.create();

		// add(new MonospaceText(100, 200, 0, "HI"));

		add(new CustomButton(100, 100, "a", function(player:PlayerSlotIdentifier) {
			trace(player + ": button 1");
		}));

		add(new CustomButton(200, 100, "b", function(player:PlayerSlotIdentifier) {
			trace(player + ": button 2");
		}));

		add(new CustomButton(150, 200, "c", function(player:PlayerSlotIdentifier) {
			trace(player + ": button 3");
		}));

		InputManager.setInputType(P1, KeyboardInput);
		add(InputManager.getPlayer(P1));

		if (FlxG.gamepads.lastActive != null) {
			InputManager.setInputType(P2, ControllerInput);
			InputManager.setInputDevice(P2, FlxG.gamepads.lastActive);
			add(InputManager.getPlayer(P2));
		} else {
			trace(FlxG.gamepads.lastActive);
		}
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);

		// if (!Std.isOfType(InputManager.getPlayer(P2), ControllerInput)) {
		// if ( != null)
		// }
	}
}
