package inputManager;

import PlayerSlot.PlayerSlotIdentifier;
import cpuController.CpuController;
import flixel.input.gamepad.FlxGamepad;
import flixel.util.typeLimit.OneOfTwo;
import inputManager.GenericInput.Position;
import inputManager.controllers.GenericController;

enum Action {
    NULL;
    MENU_CONFIRM;
    MENU_CANCEL;
    MENU_ACTION;
    MENU_LEFT;
    MENU_RIGHT;
    JUMP;
    SHORT_JUMP;
    ATTACK;
    SPECIAL;
    STRONG;
    TAUNT;
    SHIELD; // might only do parries, not sure yet
    WALK;
    DIRECTION_X;
    DIRECTION_Y;
    MOVE_X;
    MOVE_Y;

    MODIFIER_X;
    MODIFIER_Y;
}

enum InputType {
    CPUInput; // used internally to indicate a cpu player
    KeyboardInput;
    KeyboardAndMouseInput;
    ControllerInput;
    NoInput;
}

enum InputDevice {
    Keyboard;
}

class InputManager {
    private static var players:Map<PlayerSlotIdentifier, GenericInput> = [
        P1 => new GenericInput(P1),
        P2 => new GenericInput(P2),
        P3 => new GenericInput(P3),
        P4 => new GenericInput(P4),
        P5 => new GenericInput(P5),
        P6 => new GenericInput(P6),
        P7 => new GenericInput(P7),
        P8 => new GenericInput(P8),
    ];

    public static function getPlayerArray():Array<GenericInput> {
        var array = [];
        for (player in InputManager.players) {
            array.push(player);
        }
        return array;
    }

    public static var enabled = false;

    public static function getPlayer(slot:PlayerSlotIdentifier) {
        return InputManager.players[slot];
    }

    public static function getPlayerSlotByProfileName(name:String):Null<PlayerSlotIdentifier> {
        if (players[P1].profile.name == name)
            return P1;
        if (players[P2].profile.name == name)
            return P2;
        if (players[P3].profile.name == name)
            return P3;
        if (players[P4].profile.name == name)
            return P4;
        if (players[P5].profile.name == name)
            return P5;
        if (players[P6].profile.name == name)
            return P6;
        if (players[P7].profile.name == name)
            return P7;
        if (players[P8].profile.name == name)
            return P8;
        return null;
    }

    public static function getPlayerByProfileName(name:String):Null<GenericInput> {
        var slot = getPlayerSlotByProfileName(name);
        if (slot == null)
            return null;
        return players[slot];
    }

    public static function setInputType(slot:PlayerSlotIdentifier, type:InputType, ?profile:String) {
        if (type == KeyboardInput) {
            players[slot].destroy();
            players[slot] = new KeyboardHandler(slot, profile);
        } else if (type == KeyboardAndMouseInput) {
            players[slot].destroy();
            players[slot] = new MouseHandler(slot, profile);
        } else if (type == ControllerInput) {
            players[slot].destroy();
            players[slot] = new GenericController(slot, profile);
        } else if (type == NoInput) {
            players[slot].destroy();
            players[slot] = new GenericInput(slot, profile);
        } else if (type == CPUInput) {
            players[slot].destroy();
            players[slot] = new CpuController(slot);
        }
    }

    public static function getFirstOpenPlayerSlot():Null<PlayerSlotIdentifier> {
        if (!players[P1].inputEnabled)
            return P1;
        if (!players[P2].inputEnabled)
            return P2;
        if (!players[P3].inputEnabled)
            return P3;
        if (!players[P4].inputEnabled)
            return P4;
        if (!players[P5].inputEnabled)
            return P5;
        if (!players[P6].inputEnabled)
            return P6;
        if (!players[P7].inputEnabled)
            return P7;
        if (!players[P8].inputEnabled)
            return P8;
        return null;
    }

    public static function getUsedGamepads():Array<FlxGamepad> {
        return InputManager.getPlayerArray().filter(input -> {
            return Std.isOfType(input, GenericController);
        }).map(input -> {
            var c:GenericController = cast input;
            return c._flixelGamepad;
        });
    }

    public static function getPlayerSlotByInput(input:OneOfTwo<FlxGamepad, InputType>):Null<PlayerSlotIdentifier> {
        if (Std.isOfType(input, InputType)) {
            var type:InputType = cast input;
            if (type == KeyboardInput || type == KeyboardAndMouseInput) {
                var matchingInputs = InputManager.getPlayerArray().filter(thisInput -> {
                    return Std.isOfType(thisInput, KeyboardHandler);
                });
                if (matchingInputs.length > 0) {
                    return matchingInputs[0].slot;
                }
            } else
                return null;
        } else {
            var gamepad:FlxGamepad = cast input;
            for (slot => input in InputManager.players) {
                if (Std.isOfType(input, GenericController)) {
                    var c:GenericController = cast input;
                    if (c._flixelGamepad == gamepad) {
                        return cast slot;
                    }
                }
            }
        }

        return null;
    }

    public static function tryToAddPlayerFromInputDevice(inputDevice:FlxGamepad):Null<GenericInput> {
        if (InputManager.getUsedGamepads().contains(inputDevice))
            return null;

        var slot = InputManager.getFirstOpenPlayerSlot();

        if (slot != null) {
            InputManager.setInputType(slot, ControllerInput);
            InputManager.setInputDevice(slot, inputDevice);
            return InputManager.getPlayer(slot);
        }
        return null;
    }

    public static function setInputDevice(slot:PlayerSlotIdentifier, inputDevice:OneOfTwo<FlxGamepad, InputDevice>) {
        if (inputDevice == Keyboard) // TODO : probably handle this better
            return;

        if (!Std.isOfType(players[slot], GenericController))
            return;

        var input:FlxGamepad = cast inputDevice;
        var player:GenericController = cast getPlayer(slot);
        player._flixelGamepad = input;
    }

    public static function getCursors():Array<Position> {
        return InputManager.getPlayerArray().map(function(p) {
            return p.getCursorPosition();
        });
    }

    public static function update(elasped:Float) {
        if (!InputManager.enabled)
            return;
        InputManager.getPlayer(P1).update(elasped);
        InputManager.getPlayer(P2).update(elasped);
        InputManager.getPlayer(P3).update(elasped);
        InputManager.getPlayer(P4).update(elasped);
        InputManager.getPlayer(P5).update(elasped);
        InputManager.getPlayer(P6).update(elasped);
        InputManager.getPlayer(P7).update(elasped);
        InputManager.getPlayer(P8).update(elasped);
    }

    public static function draw() {
        if (!InputManager.enabled)
            return;
        InputManager.getPlayer(P8).draw();
        InputManager.getPlayer(P7).draw();
        InputManager.getPlayer(P6).draw();
        InputManager.getPlayer(P5).draw();
        InputManager.getPlayer(P4).draw();
        InputManager.getPlayer(P3).draw();
        InputManager.getPlayer(P2).draw();
        InputManager.getPlayer(P1).draw();
    }
}
