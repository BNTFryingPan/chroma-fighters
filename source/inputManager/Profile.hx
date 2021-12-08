package inputManager;

import flixel.FlxG;
import flixel.input.gamepad.FlxGamepad;
import flixel.input.keyboard.FlxKey;
import flixel.util.typeLimit.OneOfFour;
import flixel.util.typeLimit.OneOfThree;
import flixel.util.typeLimit.OneOfTwo;
import inputManager.GenericInput;
import inputManager.InputHelper;
import inputManager.InputManager.Action;
import inputManager.controllers.GenericController;
import lime.system.System;

class Profile {
    public static function getProfile(name:String, useDefaultControls:Bool = false):Profile {
        // TODO : load and create the players profile
        Main.log("getting profile");
        var profile = new Profile();
        if (useDefaultControls) {
            profile.fileName = "@default";
        } else {
            profile.fileName = #if mobile System.applicationStorageDirectory #else System.userDirectory + "\\chroma_fighters" #end + "\\profiles";
        }
        profile.loadBindings();
        return profile;
    }

    public static var defaultProfile = Profile.getProfile("", true);
    public static var profiles:Array<String>;

    // public static function getFileNameOfProfileName()
    public var name:String;
    public var fileName:String;

    public static var defaultBindings:Map<Action, Array<ProfileInput>> = [
        MOVE_X => [
            ProfileInput.getFromProfileAction(LEFT_STICK_X),
            new ProfileInput({source: FlxKey.LEFT, type: AXIS, value: -1.0}),
            new ProfileInput({source: FlxKey.RIGHT, type: AXIS, value: 1.0})
        ],
        MOVE_Y => [
            ProfileInput.getFromProfileAction(LEFT_STICK_Y),
            new ProfileInput({source: FlxKey.DOWN, type: AXIS, value: -1.0}),
            new ProfileInput({source: FlxKey.UP, type: AXIS, value: 1.0})
        ],
        MODIFIER_X => [
            // used for aerials with the c-stick on controller. doesnt apply to keyboard though
            ProfileInput.getFromProfileAction(RIGHT_STICK_X)
        ],
        MODIFIER_Y => [ProfileInput.getFromProfileAction(RIGHT_STICK_Y)],
        MENU_CONFIRM => [
            ProfileInput.getFromProfileAction(FlxKey.Z),
            ProfileInput.getFromProfileAction(FACE_A)
        ],
        MENU_CANCEL => [
            ProfileInput.getFromProfileAction(FlxKey.X),
            ProfileInput.getFromProfileAction(FACE_B)
        ],
        MENU_ACTION => [
            ProfileInput.getFromProfileAction(FlxKey.C),
            ProfileInput.getFromProfileAction(FACE_X),
            ProfileInput.getFromProfileAction(FACE_Y)
        ],
        MENU_LEFT => [
            ProfileInput.getFromProfileAction(FlxKey.A),
            ProfileInput.getFromProfileAction(LEFT_TRIGGER),
            ProfileInput.getFromProfileAction(LEFT_BUMPER)
        ],
        MENU_RIGHT => [
            ProfileInput.getFromProfileAction(FlxKey.S),
            ProfileInput.getFromProfileAction(RIGHT_TRIGGER),
            ProfileInput.getFromProfileAction(RIGHT_BUMPER)
        ],
        JUMP => [
            ProfileInput.getFromProfileAction(FlxKey.X),
            ProfileInput.getFromProfileAction(FACE_X),
            ProfileInput.getFromProfileAction(FACE_Y)
        ],
        SHORT_JUMP => [
            ProfileInput.getFromProfileAction(FlxKey.V),
            ProfileInput.getFromProfileAction(RIGHT_BUMPER)
        ],
        ATTACK => [
            ProfileInput.getFromProfileAction(FlxKey.Z),
            ProfileInput.getFromProfileAction(FACE_A)
        ],
        SPECIAL => [
            ProfileInput.getFromProfileAction(FlxKey.C),
            ProfileInput.getFromProfileAction(FACE_B)
        ],
        STRONG => [ProfileInput.getFromProfileAction(FlxKey.D)],
        TAUNT => [
            ProfileInput.getFromProfileAction(FlxKey.F),
            ProfileInput.getFromProfileAction(DPAD_UP),
            ProfileInput.getFromProfileAction(DPAD_DOWN),
            ProfileInput.getFromProfileAction(DPAD_LEFT),
            ProfileInput.getFromProfileAction(DPAD_RIGHT)
        ],
        SHIELD => [
            ProfileInput.getFromProfileAction(FlxKey.S),
            ProfileInput.getFromProfileAction(LEFT_BUMPER),
            ProfileInput.getFromProfileAction(LEFT_TRIGGER),
            ProfileInput.getFromProfileAction(RIGHT_TRIGGER)
        ],
        WALK => [ProfileInput.getFromProfileAction(FlxKey.A)]
    ];

    public var bindings:Map<Action, Array<ProfileInput>> = Profile.defaultBindings;

    public function new() {}

    public function loadBindings() {
        if (this.fileName == "@default") {
            // do nothing. just keep default bindings
            return;
        }
    }

    private var player(get, never):Null<PlayerSlot>;

    private function get_player():Null<PlayerSlot> {
        var owner = PlayerSlot.getPlayerByProfileName(this.name);
        if (owner != null)
            return owner;
        return null;
    }

    @:access(flixel.input.FlxKeyManager)
    public function checkActionArray(list:Array<ProfileInput>):INPUT_STATE {
        if (this.player == null)
            return NOT_PRESSED;

        var pressed:Array<INPUT_STATE>;

        if (Std.isOfType(this.player.input, KeyboardHandler)) {
            pressed = list.map(action -> {
                if (Std.isOfType(action, GenericButton))
                    return NOT_PRESSED;

                return InputHelper.getFromFlxInput(FlxG.keys.getKey(cast action));
            });
        } else if (Std.isOfType(this.player.input, GenericController)) {
            pressed = list.map(action -> {
                if (Std.isOfType(action, Int))
                    return NOT_PRESSED;

                return (cast this.player.input).getButtonState(cast action);
            });
        } else
            return NOT_PRESSED;
        return InputHelper.or(...pressed);
    }

    public function getAction(action:Action, gamepad:FlxGamepad):INPUT_STATE {
        return NOT_PRESSED; // switch (action) {
        // case MENU_CONFIRM;
        // }
    }

    public function getActionValue(action:Action, ?gamepad:GenericController):Float {
        if (action == NULL)
            return 0.0;
        var actionValues = this.bindings[action].map(act -> act.getInputValue(gamepad));
        var output = 0.0;

        actionValues.filter(v -> {
            output += v;
            false;
        });

        if (output > 1.0)
            return 1.0;
        if (output < -1.0)
            return -1.0;
        return output;
    }

    public function getActionState(action:Action, ?gamepad:GenericController):INPUT_STATE {
        if (action == NULL)
            return NOT_PRESSED;
        var actionStates = this.bindings[action].map(act -> act.getInputState(gamepad));
        return InputHelper.or(...actionStates);
    }
}
