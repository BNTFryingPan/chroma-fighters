package inputManager.controllers;

import flixel.input.gamepad.FlxGamepad;
import inputManager.GenericInput.INPUT_STATE;
import inputManager.GenericInput.InputHelper;

enum GenericButton {
	// abxy buttons
	FACE_BUTTON_ANY;
	// platform independant
	FACE_BUTTON_RIGHT;
	FACE_BUTTON_LEFT;
	FACE_BUTTON_DOWN;
	FACE_BUTTON_UP;
	// pro controller / joycons
	FACE_BUTTON_NINTENDO_A;
	FACE_BUTTON_NINTENDO_B;
	FACE_BUTTON_NINTENDO_X;
	FACE_BUTTON_NINTENDO_Y;
	// xinput
	FACE_BUTTON_A;
	FACE_BUTTON_B;
	FACE_BUTTON_X;
	FACE_BUTTON_Y;
	// dualshock
	FACE_BUTTON_CROSS;
	FACE_BUTTON_CIRCLE;
	FACE_BUTTON_SQUARE;
	FACE_BUTTON_TRIANGLE;
	// triggers
	TRIGGER_RIGHT_FULL;
	TRIGGER_RIGHT_HALF;
	TRIGGER_RIGHT_ANY;
	ZR; // switch
	TRIGGER_LEFT_FULL;
	TRIGGER_LEFT_HALF;
	TRIGGER_LEFT_ANY;
	ZL; // switch
	// DS triggers
	R2_FULL;
	R2_HALF;
	R2_ANY;
	L2_FULL;
	L2_HALF;
	L2_ANY;
	// joycon SL + SR
	SIDE_BUTTON_LEFT;
	SIDE_BUTTON_RIGHT;
	// bumpers
	// switch
	L;
	R;
	// xinput
	BUMPER_RIGHT;
	BUMPER_LEFT;
	RB;
	LB;
	RIGHT_BUMPER;
	LEFT_BUMPER;
	// ds
	L1;
	R1;
	// start select misc
	PLUS; // switch
	START; // nintendo / gamecube
	OPTION; // ds
	MENU; // xinput
	FOREWARD; // 360?
	MINUS; // switch
	SELECT; // nintendo
	SHARE; // ds
	VIEW; // xinput
	BACKWARD; // 360?
	HOME; // nintendo
	GUIDE; // xinput
	PS; // ds
	CAPTURE; // switch
	TOUCH; // ds
	// dpad
	DPAD_ANY;
	DPAD_RIGHT;
	DPAD_LEFT;
	DPAD_DOWN;
	DPAD_UP;
	// right stick
	RIGHT_STICK_ANY;
	RIGHT_STICK_CLICK;
	RIGHT_STICK_DIG_RIGHT;
	RIGHT_STICK_DIG_LEFT;
	RIGHT_STICK_DIG_DOWN;
	RIGHT_STICK_DIG_UP;
	// left stick
	LEFT_STICK_ANY;
	LEFT_STICK_CLICK;
	LEFT_STICK_DIG_RIGHT;
	LEFT_STICK_DIG_LEFT;
	LEFT_STICK_DIG_DOWN;
	LEFT_STICK_DIG_UP;
	// other misc
	BOTH_BUMPERS_OR_TRIGGERS; // only if SL+SR or L+R (LB+RB, L1+R1) or ZL+ZR (LT+RT, L2+R2) are pressed
	MENU_CONFIRM; // whatever the usual "confirm" button is
	MENU_CANCEL; // whatever the usual "cancel" button is
	MENU_ACTION; // x/y on x/s controllers probably
	MENU_LEFT; // left bumper/trigger/side
	MENU_RIGHT; // right bumper/trigger/side
}

class GenericController extends GenericInput {
	/**
		the raw flixel gamepad associated with this input handler
	**/
	public var _flixelGamepad(default, set):FlxGamepad;

	function set__flixelGamepad(newInput:FlxGamepad):FlxGamepad {
		this._flixelGamepad = newInput;
		this.handleNewInput();
		return newInput;
	}

	private function handleNewInput() {}

	public function getButtonState(button:GenericButton):INPUT_STATE {
		return switch (button) {
			case MENU_CONFIRM:
				this._flixelGamepad.pressed.A ? PRESSED : NOT_PRESSED;
			default:
				NOT_PRESSED;
		}
	}

	override public function getConfirm():INPUT_STATE {
		return getButtonState(MENU_CONFIRM);
	}

	override public function getCancel():INPUT_STATE {
		return getButtonState(MENU_CANCEL);
	}

	override public function getMenuAction():INPUT_STATE {
		return getButtonState(MENU_ACTION);
	}

	override public function getMenuLeft():INPUT_STATE {
		return getButtonState(MENU_LEFT);
	}

	override public function getMenuRight():INPUT_STATE {
		return getButtonState(MENU_RIGHT);
	}

	override public function getAttack():INPUT_STATE {
		return getButtonState(FACE_BUTTON_RIGHT);
	}

	override public function getJump():INPUT_STATE {
		return InputHelper.or(getButtonState(FACE_BUTTON_UP), getButtonState(FACE_BUTTON_LEFT));
	}

	override public function getSpecial():INPUT_STATE {
		return getButtonState(FACE_BUTTON_DOWN);
	}

	override public function getStrong():INPUT_STATE {
		return getButtonState(MENU_CONFIRM);
	}

	override public function getDodge():INPUT_STATE {
		return getButtonState(ZL);
	}

	override public function getWalk():INPUT_STATE {
		return getButtonState(MENU_CONFIRM);
	}

	override public function getTaunt():INPUT_STATE {
		return getButtonState(DPAD_ANY);
	}

	override public function getQuit():INPUT_STATE {
		return getButtonState(MINUS);
	}

	override public function getPause():INPUT_STATE {
		return getButtonState(PLUS);
	}

	override public function getUp():Float {
		return -Math.min(this._flixelGamepad.getYAxis(LEFT_ANALOG_STICK), 0);
	}

	override public function getDown():Float {
		return Math.max(this._flixelGamepad.getYAxis(LEFT_ANALOG_STICK), 0);
	}

	override public function getLeft():Float {
		return -Math.min(this._flixelGamepad.getXAxis(LEFT_ANALOG_STICK), 0);
	}

	override public function getRight():Float {
		return Math.max(this._flixelGamepad.getXAxis(LEFT_ANALOG_STICK), 0);
	}

	override public function getStick():StickVector {
		// TODO : make this check the control scheme first!
		var x:Float = 0;
		var y:Float = 0;

		x += this.getRight();
		x -= this.getLeft();
		y += this.getDown();
		y -= this.getUp();

		return new StickVector(x, y);
	}

	override public function getCursorStick():StickVector {
		return this.getStick().normalize();
	}

	override public function getDirection():StickVector {
		return new StickVector(0, 0);
	}

	override public function getRawDirection():StickVector {
		return new StickVector(0, 0);
	}
}
