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

enum PlayerType {
	NONE;
	CPU;
	PLAYER;
}

class PlayerSlot extends FlxBasic {
	private static var players:Array<PlayerSlot> = [];

	public var type:PlayerType = NONE;

	public function new() {
		super();
	}
}
