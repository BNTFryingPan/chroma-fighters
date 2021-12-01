package inputManager;

import flixel.FlxG;
import flixel.input.gamepad.FlxGamepad;
import flixel.input.keyboard.FlxKey;
import flixel.util.typeLimit.OneOfFour;
import flixel.util.typeLimit.OneOfThree;
import flixel.util.typeLimit.OneOfTwo;
import inputManager.GenericInput.INPUT_STATE;
import inputManager.GenericInput.InputHelper;
import inputManager.InputManager.Action;
import inputManager.controllers.GenericController;
import lime.system.System;

typedef ProfileInputSource = OneOfThree<FlxKey, GenericButton, GenericAxis>;
typedef ProfileActionSource = OneOfFour<FlxKey, GenericButton, GenericAxis, ProfileInput>;

enum ProfileInputType {
    AXIS;
    BUTTON;
}

typedef ProfileInputOptions = {
    public var type:ProfileInputType; // the type of output this input is (axis or button)
    public var source:ProfileInputSource; // the actual button or axis of the input
    // if source is axis
    public var ?deadzone:Float; // if axis value is less than this value, it becomes 0
    // button options
    public var ?minThreshold:Float; // if the source type is an axis, the lowest axis value to trigger this button
    public var ?maxThreshold:Float; // ^ but the max value. could be used for different actions at different values
    // axis options
    public var ?digitalThreshold:Float; // the minimum value of the axis to count as a digital input (not sure when itll be used though)
    public var ?value:Float; // the axis value if the source type is a button
}

class ProfileInput {
    public static function getFromProfileAction(action:ProfileAction):ProfileInput {
        if (Std.isOfType(action, ProfileInput))
            return cast action;

        if (Std.isOfType(action, GenericAxis)) {
            return new ProfileInput({
                type: AXIS,
                source: cast action,
                digitalThreshold: 0.25,
                deadzone: 0.05,
                minThreshold: 0.05,
                maxThreshold: 1
            });
        }
        // must be FlxKey or GenericButton
        return new ProfileInput({
            type: BUTTON,
            source: cast action,
            value: 1,
        });
    }

    private var source:ProfileInputSource;
    private var rawOptions:ProfileInputOptions;

    public final type:ProfileInputType;

    public var deadzone:Null<Float> = 0.05;
    public var minThreshold:Null<Float> = 0.05;
    public var maxThreshold:Null<Float> = 1;
    public var digitalThreshold:Null<Float> = 0.25;
    public var value:Null<Float> = 1;

    public function new(options:ProfileInputOptions) {
        this.rawOptions = options;
        this.type = options.type;
        this.source = options.source;

        if (this.type == BUTTON) {
            if (Std.isOfType(this.source, GenericAxis)) {
                this.minThreshold = options.minThreshold;
                this.maxThreshold = options.maxThreshold;
            } else {}
        }
    }

    public function getDigitalState(?gamepad:GenericController):Bool {
        if (Std.isOfType(this.source, FlxKey)) {
            return InputHelper.isPressed(InputHelper.getFromFlxKey(cast this.source));
        } else {
            if (Std.isOfType(gamepad, Null)) {
                return false;
            } else if (Std.isOfType(this.source, GenericButton)) {
                return InputHelper.isPressed(gamepad.getButtonState(cast this.source));
            } else {
                return (axisValue > this.digitalThreshold ? true : false);
            }
        }
    }

    public function getInputState(?gamepad:GenericController):INPUT_STATE {
        if (this.type == AXIS) {
            return NOT_PRESSED; // you cant really "press" an output axis. axis input can be "pressed" though
        }
        if (Std.isOfType(this.source, FlxKey)) {
            return InputHelper.getFromFlxKey(cast this.source);
        }
        if (Std.isOfType(this.source, GenericButton)) {
            return gamepad.getButtonState(cast this.source);
        }

        return NOT_PRESSED; // fall back
    }

    /**
    * returns the actual value of the input as a float between -1.0 or 0.0 and 1.0
    **/
    public function getInputValue(?gamepad:GenericController):Float {
        if (this.type == AXIS) {
            else if (Std.isOfType(this.source, FlxKey) || Std.isOfType(this.source, GenericButton)) {
                return this.value;
            }
            else if (this.deadzone < axisValue) {
                return axisValue;
            }
        } else {
            if (Std.isOfType(this.source, GenericAxis)) {
                if (this.minThreshold < axisValue && axisValue < this.maxThreshold) {
                    return 1.0
                }
            } else if (this.getDigitalState(gamepad)) {
                return 1.0;
            }
        }
        return 0.0
    }
}

class Profile {
    public static function getProfile(name:String, useDefaultControls:Bool = false):Profile {
        // TODO : load and create the players profile
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

    public static var defaultBindings:Map<Action, Array<ProfileAction>> = [
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

    public var bindings:Map<Action, Array<ProfileAction>> = Profile.defaultBindings;

    public function new() {}

    public function loadBindings() {
        if (this.fileName == "@default") {
            // do nothing. just keep default bindings
            return;
        }
    }

    private var input:Null<GenericInput>;

    private function getOwningPlayerFromInputManager():Null<GenericInput> {
        if (this.input != null)
            return this.input;

        var owner = InputManager.getPlayerByProfileName(this.name);
        if (owner == null)
            return null;

        this.input = owner;
        return this.input;
    }

    @:access(flixel.input.FlxKeyManager)
    public function checkActionArray(list:Array<ProfileAction>):INPUT_STATE {
        if (this.getOwningPlayerFromInputManager() == null)
            return NOT_PRESSED;

        var pressed:Array<INPUT_STATE>;

        if (Std.isOfType(this.input, KeyboardHandler))
            pressed = list.map(action -> {
                if (Std.isOfType(action, GenericButton))
                    return NOT_PRESSED;

                return InputHelper.getFromFlxInput(FlxG.keys.getKey(cast action));
            });
        else if (Std.isOfType(this.input, GenericController))
            pressed = list.map(action -> {
                if (Std.isOfType(action, Int))
                    return NOT_PRESSED;

                return (cast this.input).getButtonState(cast action);
            });
        else
            return NOT_PRESSED;
        return InputHelper.or(...pressed);
    }

    public function getAction(action:Action, gamepad:FlxGamepad):INPUT_STATE {
        return NOT_PRESSED; // switch (action) {
        // case MENU_CONFIRM;
        // }
    }
}
