package inputManager;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.ui.FlxButton;

typedef Position = {
	var x:Int;
	var y:Int;
}

/**
	A basic input handler, used as a base for all other input types.

	this handler always returns false for any input checks, and reports the cursor position as (0, 0)
**/
class GenericInput extends FlxBasic {
	public var cursorSprite:FlxSprite;
	public var cursor:Position = {x: Math.round(FlxG.width / 2), y: Math.round(FlxG.height / 2)};
	public var debugText:FlxText;

	public function new() {
		super();

		this.cursorSprite = new FlxSprite();
		this.cursorSprite.loadGraphic(AssetHelper.getImageAsset(NamespacedKey.ofDefaultNamespace("images/test_cursor")));
		this.cursor = {x: 0, y: 0};

		this.debugText.text = '';
	}

	override function update(elapsed:Float) {
		var stick = getStick();

		this.cursor.x += Math.round(stick.x * 5);
		this.cursor.y += Math.round(stick.y * 5);

		this.cursor.x = Std.int(Math.min(this.cursor.x, FlxG.width));
		this.cursor.x = Std.int(Math.max(this.cursor.x, 0));
		this.cursor.y = Std.int(Math.min(this.cursor.y, FlxG.height));
		this.cursor.y = Std.int(Math.max(this.cursor.y, 0));

		super.update(elapsed);

		if (this.getConfirm()) {
			for (mem in FlxG.state.members) {
				if (Std.isOfType(mem, FlxButton)) {
					var button:FlxButton = cast mem;
					if (button.overlapsPoint(FlxPoint.get(this.cursor.x, this.cursor.y))) {
						button.onUp.fire();
					}
				}
			}
		}
	}

	override function draw() {
		super.draw();
		this.cursorSprite.draw();
	}

	/**
		returns the screen position where the cursor should be drawn and the "click point"
	**/
	public function getCursorPosition():Position {
		return this.cursor;
	}

	public function getConfirm():Bool {
		return false;
	}

	public function getCancel():Bool {
		return false;
	}

	public function getAttack():Bool {
		return false;
	}

	public function getJump():Bool {
		return false;
	}

	public function getSpecial():Bool {
		return false;
	}

	public function getStrong():Bool {
		return false;
	}

	public function getTaunt():Bool {
		return false;
	}

	public function getQuit():Bool {
		return false;
	}

	public function getPause():Bool {
		return false;
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
