package;

import flixel.FlxBasic;

enum abstract PlayerSlotIdentifier(Int) to Int {
    var P1;
    var P2;
    var P3;
    var P4;
    var P5;
    var P6;
    var P7;
    var P8;
}

typedef PlayerColor = {
    var red:Float;
    var green:Float;
    var blue:Float;
}

enum PlayerType {
    NONE;
    CPU;
    PLAYER;
}

class PlayerSlot extends FlxBasic {
    private static var players:Array<PlayerSlot> = [];
    public static final defaultPlayerColors:Map<PlayerSlotIdentifier, PlayerColor> = [
        P1 => {red: 1.0, green: 0.2, blue: 0.2}, // red
        P2 => {red: 0.2, green: 0.2, blue: 1.0}, // blue
        P3 => {red: 0.2, green: 1.0, blue: 0.2}, // green
        P4 => {red: 1.0, green: 1.0, blue: 0.2}, // yellow
        P5 => {red: 1.0, green: 0.2, blue: 1.0}, // magenta
        P6 => {red: 0.2, green: 1.0, blue: 1.0}, // teal
        P7 => {red: 1.0, green: 0.5, blue: 0.0}, // orange
        P8 => {red: 0.5, green: 0.5, blue: 0.5}, // gray
    ];
    public static final cpuPlayerColor:PlayerColor = {red: 0.4, green: 0.4, blue: 0.4};

    public var type:PlayerType = NONE;

    public function new() {
        super();
    }
}
