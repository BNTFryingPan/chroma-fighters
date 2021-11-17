package;

import PlayerSlot.PlayerSlotIdentifier;
import flixel.math.FlxPoint;
import flixel.ui.FlxButton;
import inputManager.InputManager;

class CustomButton extends FlxButton {
    public var cursorOnDown:Null<PlayerSlotIdentifier->Void> = null;
    public var cursorOnUp:Null<PlayerSlotIdentifier->Void> = null;
    public var cursorOnOver:Null<PlayerSlotIdentifier->Void> = null;
    public var cursorOnOut:Null<PlayerSlotIdentifier->Void> = null;

    private var currentHoveredCursors:Map<PlayerSlotIdentifier, Bool> = [
        P1 => false,
        P2 => false,
        P3 => false,
        P4 => false,
        P5 => false,
        P6 => false,
        P7 => false,
        P8 => false
    ];

    private var currentClickedCursors:Map<PlayerSlotIdentifier, Bool> = [
        P1 => false,
        P2 => false,
        P3 => false,
        P4 => false,
        P5 => false,
        P6 => false,
        P7 => false,
        P8 => false
    ];

    private function getIsClickedBy(slot:PlayerSlotIdentifier):Bool {
        if (this.currentHoveredCursors.get(slot) == true) {
            return this.currentClickedCursors.get(slot) == true;
        }
        return false;
    }

    public function new(x:Float = 0, y:Float = 0, ?text:String, ?onClick:PlayerSlotIdentifier->Void) {
        super(x, y, text);
        this.cursorOnUp = onClick;
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

    function updateState() {
        var isHovered:Bool = false;
        var isClicked:Bool = false;
        for (slot => state in this.currentHoveredCursors.keyValueIterator())
            if (state) {
                isHovered = true;
                break;
            }

        if (isHovered)
            for (slot => state in this.currentClickedCursors.keyValueIterator())
                if (state) {
                    isClicked = true;
                    break;
                }

        if (isClicked) {
            this.status = FlxButton.PRESSED;
        } else if (isHovered) {
            this.status = FlxButton.HIGHLIGHT;
        } else {
            this.status = FlxButton.NORMAL;
        }
    }

    public function overHandler(slot:PlayerSlotIdentifier) {
        if (this.currentHoveredCursors.get(slot) == true)
            return;
        this.currentHoveredCursors.set(slot, true);
        this.updateState();
        if (this.cursorOnOver != null)
            this.cursorOnOver(slot);
    }

    public function upHandler(slot:PlayerSlotIdentifier) {
        if (this.currentClickedCursors.get(slot) == false)
            return;
        this.currentClickedCursors.set(slot, false);
        this.updateState();
        if (this.cursorOnUp != null)
            this.cursorOnUp(slot);
    }

    public function outHandler(slot:PlayerSlotIdentifier) {
        if (this.currentHoveredCursors.get(slot) == false)
            return;
        this.currentHoveredCursors.set(slot, false);
        this.updateState();
        if (this.cursorOnOut != null)
            this.cursorOnOut(slot);
    }

    public function downHandler(slot:PlayerSlotIdentifier) {
        if (this.currentClickedCursors.get(slot) == true)
            return;
        this.currentClickedCursors.set(slot, true);
        this.updateState();
        if (this.cursorOnDown != null)
            this.cursorOnDown(slot);
    }

    override function updateButton() {
        return; // i think i literally need to do nothing here lol
    }
}
