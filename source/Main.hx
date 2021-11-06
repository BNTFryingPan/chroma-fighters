package;

import flixel.FlxG;
import flixel.FlxGame;
import openfl.display.Sprite;
import states.PlayState;

class Main extends Sprite {
	public function new() {
		super();
		FlxG.log.redirectTraces = true;
		addChild(new FlxGame(0, 0, PlayState, 1, 60, 60, true, false));
	}
}
