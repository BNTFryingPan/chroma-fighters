package inputManager;

import PlayerSlot.PlayerSlotIdentifier;
import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;

typedef Position = {
	var x:Int;
	var y:Int;
}

enum INPUT_STATE {
	JUST_PRESSED;
	JUST_RELEASED;
	PRESSED;
	NOT_PRESSED;
}

class InputHelper {
	static public function isPressed(state:INPUT_STATE) {
		if (state == JUST_PRESSED) {
			return true;
		}
		return state == PRESSED;
	}

	static public function isNotPressed(state:INPUT_STATE) {
		if (state == JUST_RELEASED) {
			return true;
		}
		return state == NOT_PRESSED;
	}

	static public function justChanged(state:INPUT_STATE) {
		if (state == JUST_PRESSED) {
			return true;
		}
		return state == JUST_RELEASED;
	}

	static public function notChanged(state:INPUT_STATE) {
		if (state == PRESSED) {
			return true;
		}
		return state == NOT_PRESSED;
	}

	static public function getFromFlixel(justPressed:Bool, justReleased:Bool, pressed:Bool) {
		if (justPressed)
			return JUST_PRESSED;
		if (justReleased)
			return JUST_RELEASED;
		if (pressed)
			return PRESSED;
		return NOT_PRESSED;
	}
}

enum CursorRotation {
	LEFT;
	RIGHT;
	UP_LEFT;
	UP_RIGHT;
	DOWN_LEFT;
	DOWN_RIGHT;
}

/**
	A basic input handler, used as a base for all other input types.

	this handler always returns false for any input checks, and reports the cursor position as (0, 0)
**/
class GenericInput extends FlxBasic {
	public var cursorSprite:FlxSprite;
	public var coinSprite:FlxSprite;
	public var debugSprite:FlxSprite;
	public var cursor:Position = {x: Math.round(FlxG.width / 2), y: Math.round(FlxG.height / 2)};
	public var cursorAngle:CursorRotation = RIGHT;
	public var spriteOffset:Position = {x: 0, y: 0};
	public var isvisible:Bool = true;

	public var enabled:Bool = false;

	public final slot:PlayerSlotIdentifier;

	public static function getOffset(angle:CursorRotation):Position {
		if (angle == LEFT) {
			return {x: 30, y: 15};
		} else if (angle == RIGHT) {
			return {x: 30, y: 15};
		} else if (angle == UP_LEFT) {
			return {x: 30, y: 15};
		} else if (angle == UP_RIGHT) {
			return {x: 27, y: 0};
		} else if (angle == DOWN_LEFT) {
			return {x: 30, y: 15};
		} else if (angle == DOWN_RIGHT) {
			return {x: 30, y: 15};
		}

		return {x: 30, y: 15};
	}

	public function new(slot:PlayerSlotIdentifier) {
		super();

		trace("creating generic input for slot " + slot);

		this.coinSprite = new FlxSprite();
		this.coinSprite.loadGraphic(AssetHelper.getImageAsset(NamespacedKey.ofDefaultNamespace("images/cursor/coin")));
		this.cursorSprite = new FlxSprite();

		this.debugSprite = new FlxSprite();
		this.debugSprite.makeGraphic(3, 3, FlxColor.MAGENTA);

		this.setCursorAngle(RIGHT);

		this.cursor = {x: 0, y: 0};
		this.enabled = true;

		this.slot = slot;
	}

	public function setCursorAngle(angle:CursorRotation) {
		if (angle == LEFT) {
			this.cursorSprite.loadGraphic(AssetHelper.getImageAsset(NamespacedKey.ofDefaultNamespace("images/cursor/pointer_left")));
		} else if (angle == RIGHT) {
			this.cursorSprite.loadGraphic(AssetHelper.getImageAsset(NamespacedKey.ofDefaultNamespace("images/cursor/pointer_right")));
		} else if (angle == UP_LEFT) {
			this.cursorSprite.loadGraphic(AssetHelper.getImageAsset(NamespacedKey.ofDefaultNamespace("images/cursor/pointer_up_left")));
		} else if (angle == UP_RIGHT) {
			this.cursorSprite.loadGraphic(AssetHelper.getImageAsset(NamespacedKey.ofDefaultNamespace("images/cursor/pointer_up_right")));
		} else if (angle == DOWN_LEFT) {
			this.cursorSprite.loadGraphic(AssetHelper.getImageAsset(NamespacedKey.ofDefaultNamespace("images/cursor/pointer_down_left")));
		} else if (angle == DOWN_RIGHT) {
			this.cursorSprite.loadGraphic(AssetHelper.getImageAsset(NamespacedKey.ofDefaultNamespace("images/cursor/pointer_down_right")));
		}

		this.spriteOffset = GenericInput.getOffset(angle);
	}

	function updateCursorPos(elapsed:Float) {
		var stick = getStick();

		this.cursor.x += Math.round(stick.x * 5);
		this.cursor.y += Math.round(stick.y * 5);

		this.cursor.x = Std.int(Math.min(this.cursor.x, FlxG.width));
		this.cursor.x = Std.int(Math.max(this.cursor.x, 0));
		this.cursor.y = Std.int(Math.min(this.cursor.y, FlxG.height));
		this.cursor.y = Std.int(Math.max(this.cursor.y, 0));
	}

	override function update(elapsed:Float) {
		this.updateCursorPos(elapsed);
		var cursorPos = this.getCursorPosition();

		this.cursorSprite.x = cursorPos.x - this.spriteOffset.x;
		this.cursorSprite.y = cursorPos.y - this.spriteOffset.y;

		this.debugSprite.x = cursorPos.x;
		this.debugSprite.y = cursorPos.y;

		super.update(elapsed);

		if (this.enabled) {
			for (mem in FlxG.state.members) {
				if (Std.isOfType(mem, CustomButton)) {
					var button:CustomButton = cast mem;
					if (button.overlapsPoint(FlxPoint.get(cursorPos.x, cursorPos.y))) {
						button.overHandler(this.slot);
						if (InputHelper.isPressed(this.getConfirm()))
							button.downHandler(this.slot);
						else
							button.upHandler(this.slot);
					} else
						button.outHandler(this.slot);
				}
			}
		}

		// if (this.isvisible)
		Main.debugDisplay.leftAppend += '\n[P${this.slot + 1}] cursor: (${this.cursor.x}, ${this.cursor.y})\nstick: ${this.getStick()}\ncon ${this.getConfirm()} can ${this.getCancel()}\n';
	}

	override function draw() {
		if (!this.enabled)
			return;
		super.draw();
		this.cursorSprite.draw();

		this.debugSprite.draw();
	}

	/**
		returns the screen position where the cursor should be drawn and the "click point"
	**/
	public function getCursorPosition():Position {
		return this.cursor;
	}

	public function getConfirm():INPUT_STATE {
		return NOT_PRESSED;
	}

	public function getCancel():INPUT_STATE {
		return NOT_PRESSED;
	}

	public function getMenuAction():INPUT_STATE {
		return NOT_PRESSED;
	}

	public function getMenuLeft():INPUT_STATE {
		return NOT_PRESSED;
	}

	public function getMenuRight():INPUT_STATE {
		return NOT_PRESSED;
	}

	public function getAttack():INPUT_STATE {
		return NOT_PRESSED;
	}

	public function getJump():INPUT_STATE {
		return NOT_PRESSED;
	}

	public function getSpecial():INPUT_STATE {
		return NOT_PRESSED;
	}

	public function getStrong():INPUT_STATE {
		return NOT_PRESSED;
	}

	public function getDodge():INPUT_STATE {
		return NOT_PRESSED;
	}

	public function getWalk():INPUT_STATE {
		return NOT_PRESSED;
	}

	public function getTaunt():INPUT_STATE {
		return NOT_PRESSED;
	}

	public function getQuit():INPUT_STATE {
		return NOT_PRESSED;
	}

	public function getPause():INPUT_STATE {
		return NOT_PRESSED;
	}

	public function getUp():Float {
		return 0;
	}

	public function getDown():Float {
		return 0;
	}

	public function getLeft():Float {
		return 0;
	}

	public function getRight():Float {
		return 0;
	}

	public function getStick():StickVector {
		return new StickVector(0, 0);
	}

	public function getDirection():StickVector {
		return new StickVector(0, 0);
	}

	public function getRawDirection():StickVector {
		return new StickVector(0, 0);
	}
}
