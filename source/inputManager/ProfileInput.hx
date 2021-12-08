package inputManager;

import flixel.input.keyboard.FlxKey;
import inputManager.GenericInput;
import inputManager.InputHelper;
import inputManager.controllers.GenericController;
import inputManager.InputEnums;
import inputManager.InputTypes;

class ProfileInput {
    public static function getFromProfileAction(action:ProfileActionSource):ProfileInput {
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
            }
        }
    }

    private function isDigitalSource():Bool {
        return (Std.isOfType(this.source, Int) || Std.isOfType(this.source, GenericButton));
    }

    private function getAxisValue(?gamepad:GenericController):Float {
        if (this.isDigitalSource())
            return 0.0;
        return 0.0;
    }

    public function getDigitalState(?gamepad:GenericController):Bool {
        if (Std.isOfType(this.source, Int)) {
            return InputHelper.isPressed(InputHelper.getFromFlxKey(cast this.source));
        } else if (gamepad == null) {
            return false;
        } else if (Std.isOfType(this.source, GenericButton)) {
            return InputHelper.isPressed(gamepad.getButtonState(cast this.source));
        }
        return (this.getAxisValue() > this.digitalThreshold ? true : false);
    }

    public function getInputState(?gamepad:GenericController):INPUT_STATE {
        if (this.type == AXIS) {
            return NOT_PRESSED; // you cant really "press" an output axis. axis input can be "pressed" though
        }
        if (Std.isOfType(this.source, Int)) {
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
            if (this.isDigitalSource())
                return this.getDigitalState(gamepad) ? this.value : 0.0;
            return this.getAxisValue() > this.deadzone ? this.getAxisValue() : 0.0;
        } else if (this.getDigitalState(gamepad)) {
            return 1.0;
        }
        return 0.0;
    }

    // else {
    //     if (Std.isOfType(this.source, GenericAxis)) {
    //         if (this.minThreshold < axisValue && axisValue < this.maxThreshold) {
    //             return 1.0
    //         }
    //     } else if (this.getDigitalState(gamepad)) {
    //         return 1.0;
    //     }
    // }
    //     return 0.0
    // }
}