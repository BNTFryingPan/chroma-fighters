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

class PlayerBox extends FlxBasic {
    public var inputTypeText:FlxText;
    public var labelText:FlxText;
    public var background:FlxSprite;
    public var SwapButton:CustomButton;
    public var disconnectButton:CustomButton;

    public var slot = 1;
    public var max = 2;
    public var xPos = 10;

    public function new() {
        this.background = new FlxSprite();
        this.background.makeGraphic(10, 10, FlxColor.MAGENTA);
    }

    public override function update(elapsed:Float) {
        super.update();
        this.background.update();
    }

    public override function draw() {
        super.draw();
        this.background.draw();
    }

    public function drawCSS(slot:Int, max:Int) {
        var xPos = Math.floor((FlxG.width * 0.9) / max + 1) * (Math.floor((FlxG.width * 0.9) / max) * slot);
    }
}

class PlayerSlot extends FlxBasic {
    public static final artificalPlayerLimit = true; // if true, caps at 4 players instead of 8 at runtime. might break stuff, idk

    public static var players:Map<PlayerSlotIdentifier, Null<PlayerSlot>> = [
        P1 => new PlayerSlot(P1),
        P2 => new PlayerSlot(P2),
        P3 => new PlayerSlot(P3),
        P4 => new PlayerSlot(P4),
        P5 => new PlayerSlot(P5),
        P6 => new PlayerSlot(P6),
        P7 => new PlayerSlot(P7),
        P8 => new PlayerSlot(P8),
    ];
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

    public static function getPlayer(slot:PlayerSlotIdentifier) {
        return PlayerSlot.players[slot];
    }

    public static function getNumberOfPlayerSlotsToDraw():Int {
        if (!PlayerSlot.artificalPlayerLimit) {
            if (PlayerSlot.players[P8].type != NONE)
                return 8;
            if (PlayerSlot.players[P7].type != NONE)
                return 7;
            if (PlayerSlot.players[P6].type != NONE)
                return 6;
            if (PlayerSlot.players[P5].type != NONE)
                return 5;
        }
        if (PlayerSlot.players[P4].type != NONE)
            return 4;
        if (PlayerSlot.players[P3].type != NONE)
            return 3;
        return 2;
    }

    public static function getPlayerArray(?skipEmpty:Bool):Array<PlayerSlot> {
        var array = [];
        for (player in PlayerSlot.players) {
            if ((!skipEmpty) || (player.type != NONE)) {
                array.push(player);
            }
        }
        return array;
    }

    public static function getPlayerInputArray(?skipEmpty:Bool):Array<GenericInput> {
        return PlayerSlot.getPlayerArray(skipEmpty).map(player -> player.input);
    }

    public static function getPlayerSlotByInput(input:OneOfTwo<FlxGamepad, InputType>):Null<PlayerSlotIdentifier> {
        if (Std.isOfType(input, InputType)) {
            var type:InputType = cast input;
            if (type == KeyboardInput || type == KeyboardAndMouseInput) {
                var matchingInputs = PlayerSlot.getPlayerInputArray().filter(thisInput -> {
                    return Std.isOfType(thisInput, KeyboardHandler);
                });
                if (matchingInputs.length > 0) {
                    return matchingInputs[0].slot;
                }
            }
            return null;
        }

        var gamepad:FlxGamepad = cast input;
        for (slot => player in PlayerSlot.players) {
            if (Std.isOfType(player.input, GenericController)) {
                var c:GenericController = cast player.input;
                if (c._flixelGamepad == gamepad) {
                    return cast slot;
                }
            }
        }

        return null;
    }

    public static function getPlayerByInput(input:OneOfTwo<FlxGamepad, InputType>):Null<PlayerSlot> {
        return getPlayer(getPlayerSlotByInput(input));
    }

    public static function getFirstOpenPlayerSlot():Null<PlayerSlotIdentifier> {
        if (PlayerSlot.getPlayer(P1).type == NONE)
            return P1;
        if (PlayerSlot.getPlayer(P2).type == NONE)
            return P2;
        if (PlayerSlot.getPlayer(P3).type == NONE)
            return P3;
        if (PlayerSlot.getPlayer(P4).type == NONE)
            return P4;
        if (PlayerSlot.artificalPlayerLimit)
            return null;
        if (PlayerSlot.getPlayer(P5).type == NONE)
            return P5;
        if (PlayerSlot.getPlayer(P6).type == NONE)
            return P6;
        if (PlayerSlot.getPlayer(P7).type == NONE)
            return P7;
        if (PlayerSlot.getPlayer(P8).type == NONE)
            return P8;
        return null;
    }

    public static function getFirstEmptyPlayer():Null<PlayerSlot> {
        return PlayerSlot.getPlayer(getFirstOpenPlayerSlot());
    }

    public static function tryToAddPlayerFromInputDevice(inputDevice:FlxGamepad):Null<PlayerSlot> {
        if (PlayerSlot.getPlayerByInput() != null)
            return null;

        var player = PlayerSlot.getFirstEmptyPlayer();

        if (slot == null)
            return null;

        player.setNewInput(ControllerInput, inputDevice);
        return player;
    }

    public static function updateAll(elapsed:Float) {
        PlayerSlot.getPlayerArray().filter(player -> {
            player.update(elapsed);
            return false;
        });
    }

    public static function drawAll() {
        PlayerSlot.getPlayerArray().filter(player -> {
            player.draw();
            return false;
        });
    }

    public var type:PlayerType = NONE;
    public var color:PlayerColor;
    public var slot:PlayerSlotIdentifier;
    public var input:GenericInput;

    public function setNewInput(type:InputType, ?inputDevice:OneOfTwo<FlxGamepad, InputDevice>, ?profile:String) {
        if (type == KeyboardInput || inputDevice == Keyboard) {
            this.setType(PLAYER);
            this.input.destroy();
            this.input = new KeyboardHandler(slot, profile);
        } else if (type == KeyboardAndMouseInput) {
            this.setType(PLAYER);
            this.input.destroy();
            this.input = new MouseHandler(slot, profile);
        } else if (type == ControllerInput) {
            this.setType(PLAYER);
            this.input.destroy();
            this.input = new GenericController(slot, profile);
            this.input._flixelGamepad = cast inputDevice;
        } else if (type == NoInput) {
            this.setType(NONE);
            this.input.destroy();
            this.input = new GenericInput(slot, profile);
        } else if (type == CPUInput) {
            this.setType(CPU);
            this.input.destroy();
            this.input = new CpuController(slot, profile);
        }
    }

    private function new(slot:PlayerSlotIdentifier) {
        super();
        trace("new player slot");
        this.slot = slot;
        this.type = NONE;
    }

    public function setType(type:PlayerType) {
        this.type = type;
    }

    public function moveToSlot(toSlot:PlayerSlotIdentifier) {
        if (PlayerSlot.artificalPlayerLimit && toSlot > 4)
            return;
        PlayerSlot.players[toSlot].slot = this.slot;
        this.slot = toSlot;

        PlayerSlot.players[this.slot] = PlayerSlot.players[toSlot];
        PlayerSlot.players[toSlot] = this;
    }

    public function update(elasped:Float) {
        this.input.update(elapsed);
    }

    public function draw() {
        this.input.draw();
    }
}
