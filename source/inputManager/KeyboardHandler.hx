package inputManager;

import flixel.FlxG;
import flixel.ui.FlxButton;

class KeyboardHandler extends GenericInput {
	override public function getConfirm():Bool {
		return false;
	}

	override public function getCancel():Bool {
		return false;
	}

	override public function getAttack():Bool {
		return false;
	}

	override public function getJump():Bool {
		return false;
	}

	override public function getSpecial():Bool {
		return false;
	}

	override public function getStrong():Bool {
		return false;
	}

	override public function getTaunt():Bool {
		return false;
	}

	override public function getQuit():Bool {
		return false;
	}

	override public function getPause():Bool {
		return false;
	}

	override public function getUp():Float {
		return FlxG.keys.pressed.UP ? 1 : 0;
	}

	override public function getDown():Float {
		return FlxG.keys.pressed.DOWN ? 1 : 0;
	}

	override public function getLeft():Float {
		return FlxG.keys.pressed.LEFT ? 1 : 0;
	}

	override public function getRight():Float {
		return FlxG.keys.pressed.RIGHT ? 1 : 0;
	}

	override public function getStick():StickVector {
		// TODO : make this check the control scheme first!
		var x:Float = 0;
		var y:Float = 0;

		y -= this.getUp();
		y += this.getDown();
		x -= this.getLeft();
		y += this.getRight();

		return new StickVector(x, y);
	}

	override public function getDirection():StickVector {
		return new StickVector(0, 0);
	}

	override public function getRawDirection():StickVector {
		return new StickVector(0, 0);
	}
}
