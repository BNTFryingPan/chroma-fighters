package states;

import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import inputManager.InputManager;
import inputManager.KeyboardHandler;

class PlayState extends FlxState {
	public var input:InputManager;

	override public function create() {
		super.create();

		add(new FlxButton(100, 100, "a", function() {
			trace("Aaaaaaaaaaaaaaa");
		}));

		add(new FlxButton(200, 100, "b", function() {
			trace("bbbbadsbdfba");
		}));

		add(new FlxButton(150, 200, "c", function() {
			trace("button 3");
		}));

		add(new KeyboardHandler());
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);
	}
}
