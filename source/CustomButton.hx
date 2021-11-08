package;

import PlayerSlot.PlayerSlotIdentifier;
import flixel.math.FlxPoint;
import flixel.ui.FlxButton;
import inputManager.GenericInput.INPUT_STATE;
import inputManager.InputManager;

class CustomButton extends FlxButton {
	public var cursorOnDown:Null<PlayerSlotIdentifier->Void> = null;
	public var cursorOnUp:Null<PlayerSlotIdentifier->Void> = null;
	public var cursorOnOver:Null<PlayerSlotIdentifier->Void> = null;
	public var cursorOnOut:Null<PlayerSlotIdentifier->Void> = null;

	public function new(x:Float = 0, y:Float = 0, ?text:String, ?onClick:PlayerSlotIdentifier->Void) {
		super(x, y, text);
		this.cursorOnUp = onClick;
	}

	public function cursorClick(state:Null<INPUT_STATE>, player:PlayerSlotIdentifier) {
		if (state == JUST_PRESSED) {
			this.onDownHandler();
			this.cursorOnDown(player);
		} else if (state == JUST_RELEASED) {
			this.onUpHandler();
			this.cursorOnUp(player);
		} else if (state == NOT_PRESSED) {
			this.onOverHandler();
			this.cursorOnDown(player);
		} else if (state == null) {
			this.onOutHandler();
			this.cursorOnOut(player);
		}
	}

	function checkCursorOverlap():Array<PlayerSlotIdentifier> {
		var overlappingCursors = InputManager.getCursors().map(function(c) {
			var point = FlxPoint.get(c.x, c.y);
			var overlaps = overlapsPoint(point);
			point.put();
			return overlaps;
		});
		var output:Array<PlayerSlotIdentifier> = [];
		if (overlappingCursors[0]) {
			output.push(P1);
		}
		if (overlappingCursors[1]) {
			output.push(P2);
		}
		if (overlappingCursors[2]) {
			output.push(P3);
		}
		if (overlappingCursors[3]) {
			output.push(P4);
		}
		if (overlappingCursors[4]) {
			output.push(P5);
		}
		if (overlappingCursors[5]) {
			output.push(P6);
		}
		if (overlappingCursors[6]) {
			output.push(P7);
		}
		if (overlappingCursors[7]) {
			output.push(P8);
		}
		return output;
	}

	override function updateButton() {
		return;
		var overlapsFound = checkCursorOverlap();
		var overlapFound = overlapsFound.length > 0;

		if (currentInput != null && currentInput.justReleased && overlapFound) {
			onUpHandler();
			// clickHandler(overlapsFound);
		}

		if (status != FlxButton.NORMAL && (!overlapFound || (currentInput != null && currentInput.justReleased))) {
			onOutHandler();
		}
	}

	public function clickHandler(players:Array<PlayerSlotIdentifier>):Void {
		// Other code to run?
	}
}
