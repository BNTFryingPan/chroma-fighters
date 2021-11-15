package inputManager;

import PlayerSlot.PlayerSlotIdentifier;
import flixel.input.gamepad.FlxGamepad;
import flixel.util.typeLimit.OneOfTwo;
import inputManager.GenericInput.Position;
import inputManager.controllers.GenericController;

enum Action {
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
}

enum InputType {
    CPUInput; // used internally to indicate a cpu player
    KeyboardInput;
    KeyboardAndMouseInput;
    ControllerInput;
}

enum InputDevice {
    Keyboard;
}

class InputManager {
    private static var players:Array<GenericInput> = [
        new GenericInput(P1),
        new GenericInput(P2),
        new GenericInput(P3),
        new GenericInput(P4),
        new GenericInput(P5),
        new GenericInput(P6),
        new GenericInput(P7),
        new GenericInput(P8),
    ];

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

    public static function setInputType(slot:PlayerSlotIdentifier, type:InputType) {
        if (type == KeyboardInput) {
            players[slot] = new KeyboardHandler(slot);
        } else if (type == KeyboardAndMouseInput) {
            players[slot] = new MouseHandler(slot);
        } else if (type == ControllerInput) {
            players[slot] = new GenericController(slot);
        } else if (type == CPUInput) {
            players[slot] = new CpuController(slot);
        }
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
        return InputManager.players.map(function(p) {
            return p.getCursorPosition();
        });
    }
}
