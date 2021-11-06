package inputManager;

import flixel.FlxG;
import inputManager.GenericInput.Position;

class MouseHandler extends KeyboardHandler {
	override function getCursorPosition():Position {
		return {x: FlxG.mouse.screenX, y: FlxG.mouse.screenY}
	}
}
