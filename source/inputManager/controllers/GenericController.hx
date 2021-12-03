package inputManager.controllers;

import PlayerSlot.PlayerSlotIdentifier;
import flixel.input.gamepad.FlxGamepad;
import inputManager.GenericInput.INPUT_STATE;
import inputManager.GenericInput.InputHelper;

enum GenericAxis { // easier access to various forms of analog inputs
    LEFT_STICK_X; // -1.0 to 1.0
    LEFT_STICK_X_INV; // above but *-1
    LEFT_STICK_X_POS; // first but 0.0 to 1.0
    LEFT_STICK_X_NEG; // above but for the negative values and *-1 (so -1.0 - 1.0 -> -1.0 - 0.0 -> 0.0 - 1.0)
    LEFT_STICK_Y;
    LEFT_STICK_Y_INV;
    LEFT_STICK_Y_POS;
    LEFT_STICK_Y_NEG;
    RIGHT_STICK_X;
    RIGHT_STICK_X_INV;
    RIGHT_STICK_X_POS;
    RIGHT_STICK_X_NEG;
    RIGHT_STICK_Y;
    RIGHT_STICK_Y_INV;
    RIGHT_STICK_Y_POS;
    RIGHT_STICK_Y_NEG;
    LEFT_TRIGGER;
    RIGHT_TRIGGER;
}

enum GenericButton { // based off a combo of an xinput controller layout (xbone) and switch controller layout
    FACE_A;
    FACE_B;
    FACE_X;
    FACE_Y;
    DPAD_UP;
    DPAD_DOWN;
    DPAD_LEFT;
    DPAD_RIGHT;
    LEFT_TRIGGER;
    RIGHT_TRIGGER;
    LEFT_BUMPER;
    RIGHT_BUMPER;
    PLUS;
    MINUS;
    HOME;
    CAPTURE;
    LEFT_STICK_CLICK;
    RIGHT_STICK_CLICK;
    NULL; // used as a placeholder to always return NOT_PRESSED
    TRUE; // used as a placeholder to always return PRESSED
}

enum abstract SpecificButton(GenericButton) to GenericButton {
    // abxy buttons
    // var FACE_BUTTON_ANY = [FACE_A, FACE_B, FACE_X, FACE_Y];
    // platform independant
    // nvm this wouldnt work lol
    // FACE_BUTTON_RIGHT;
    // FACE_BUTTON_LEFT;
    // FACE_BUTTON_DOWN;
    // FACE_BUTTON_UP;
    // pro controller / joycons
    var FACE_BUTTON_NINTENDO_A = FACE_B;
    var FACE_BUTTON_NINTENDO_B = FACE_A;
    var FACE_BUTTON_NINTENDO_X = FACE_Y;
    var FACE_BUTTON_NINTENDO_Y = FACE_X;
    // xinput
    var FACE_BUTTON_A = FACE_A;
    var FACE_BUTTON_B = FACE_B;
    var FACE_BUTTON_X = FACE_X;
    var FACE_BUTTON_Y = FACE_Y;
    // dualshock
    var FACE_BUTTON_CROSS = FACE_A;
    var FACE_BUTTON_CIRCLE = FACE_B;
    var FACE_BUTTON_SQUARE = FACE_X;
    var FACE_BUTTON_TRIANGLE = FACE_Y;
    // triggers
    var TRIGGER_RIGHT_FULL = RIGHT_TRIGGER;
    // TRIGGER_RIGHT_HALF;
    // TRIGGER_RIGHT_ANY;
    var ZR = RIGHT_TRIGGER; // switch
    var TRIGGER_LEFT_FULL = LEFT_TRIGGER;
    // TRIGGER_LEFT_HALF;
    // TRIGGER_LEFT_ANY;
    var ZL = LEFT_TRIGGER; // switch
    // DS triggers
    var R2_FULL = RIGHT_TRIGGER;
    // R2_HALF;
    // R2_ANY;
    var L2_FULL = LEFT_TRIGGER;
    // L2_HALF;
    // L2_ANY;
    // joycon SL + SR
    var SIDE_BUTTON_LEFT = LEFT_BUMPER;
    var SIDE_BUTTON_RIGHT = LEFT_BUMPER;
    // bumpers
    // switch
    var L = LEFT_BUMPER;
    var R = RIGHT_BUMPER;
    // xinput
    var BUMPER_RIGHT = RIGHT_BUMPER;
    var BUMPER_LEFT = LEFT_BUMPER;
    var RB = RIGHT_BUMPER;
    var LB = LEFT_BUMPER;
    var RIGHT_BUMPER = GenericButton.RIGHT_BUMPER;
    var LEFT_BUMPER = GenericButton.LEFT_BUMPER;
    // gamecube?
    var Z = LEFT_BUMPER;
    // ds
    var L1 = LEFT_BUMPER;
    var R1 = RIGHT_BUMPER;
    // start select misc
    var PLUS = GenericButton.PLUS; // switch
    var START = PLUS; // nintendo / gamecube
    var OPTION = PLUS; // ds
    var MENU = PLUS; // xinput
    var FOREWARD = PLUS; // 360?
    var MINUS = GenericButton.MINUS; // switch
    var SELECT = MINUS; // nintendo
    var SHARE = MINUS; // ds
    var VIEW = MINUS; // xinput
    var BACKWARD = MINUS; // 360?
    var HOME = GenericButton.HOME; // nintendo
    var GUIDE = HOME; // xinput
    var PS = HOME; // ds
    var CAPTURE = GenericButton.CAPTURE; // switch
    var TOUCH = CAPTURE; // ds
    // dpad
    var DPAD_RIGHT = GenericButton.DPAD_RIGHT;
    var DPAD_LEFT = GenericButton.DPAD_LEFT;
    var DPAD_DOWN = GenericButton.DPAD_DOWN;
    var DPAD_UP = GenericButton.DPAD_UP;
    // right stick
    // RIGHT_STICK_ANY;
    var RIGHT_STICK_CLICK = GenericButton.RIGHT_STICK_CLICK;
    // RIGHT_STICK_DIG_RIGHT;
    // RIGHT_STICK_DIG_LEFT;
    // RIGHT_STICK_DIG_DOWN;
    // RIGHT_STICK_DIG_UP;
    // left stick
    // LEFT_STICK_ANY;
    var LEFT_STICK_CLICK = GenericButton.LEFT_STICK_CLICK;
    // LEFT_STICK_DIG_RIGHT;
    // LEFT_STICK_DIG_LEFT;
    // LEFT_STICK_DIG_DOWN;
    // LEFT_STICK_DIG_UP;
    // other misc
    // BOTH_BUMPERS_OR_TRIGGERS; // only if SL+SR or L+R (LB+RB, L1+R1) or ZL+ZR (LT+RT, L2+R2) are pressed
}

class GenericController extends GenericInput {
    /**
        the raw flixel gamepad associated with this input handler
    **/
    public var _flixelGamepad(default, set):FlxGamepad;

    override public function get_inputType() {
        return "Controller (Generic)";
    }

    override public function get_inputEnabled() {
        if (this._flixelGamepad.connected != true) {
            // Main.log('controller connected: ${this._flixelGamepad.connected}');
            return false;
        }

        return true;
    }

    public function new(slot:PlayerSlotIdentifier, ?profile:String) {
        super(slot, profile);
    }

    function set__flixelGamepad(newInput:FlxGamepad):FlxGamepad {
        this._flixelGamepad = newInput;
        this.handleNewInput();
        return newInput;
    }

    private function handleNewInput() {}

    @:access(flixel.input.gamepad.FlxGamepad)
    public function getFromFlixelGamepadButton(button:FlxGamepadButton):INPUT_STATE {
        return InputHelper.getFromFlxInput(this._flixelGamepad.getButton(this._flixelGamepad.mapping.getRawID(button)))
    }

    public function getButtonState(button:GenericButton):INPUT_STATE {
        if (this._flixelGamepad.connected != true) {
            return NOT_PRESSED;
        }
        return switch (button) {
            case NULL:
                NOT_PRESSED;
            case TRUE:
                PRESSED;
            case FACE_A:
                this.getFromFlixelGamepadButton(A);
            case FACE_B:
                this.getFromFlixelGamepadButton(B);
            case FACE_X:
                this.getFromFlixelGamepadButton(X);
            case FACE_Y:
                this.getFromFlixelGamepadButton(Y);
            case DPAD_UP:
                this.getFromFlixelGamepadButton(DPAD_UP);
            case DPAD_DOWN:
                this.getFromFlixelGamepadButton(DPAD_DOWN);
            case DPAD_LEFT:
                this.getFromFlixelGamepadButton(DPAD_LEFT);
            case DPAD_RIGHT:
                this.getFromFlixelGamepadButton(DPAD_RIGHT);
            case LEFT_TRIGGER:
                this.getFromFlixelGamepadButton(LEFT_TRIGGER);
            case RIGHT_TRIGGER:
                this.getFromFlixelGamepadButton(RIGHT_TRIGGER);
            case LEFT_BUMPER:
                this.getFromFlixelGamepadButton(LEFT_SHOULDER);
            case RIGHT_BUMPER:
                this.getFromFlixelGamepadButton(RIGHT_SHOULDER);
            case LEFT_STICK_CLICK:
                this.getFromFlixelGamepadButton(LEFT_STICK_CLICK);
            case RIGHT_STICK_CLICK:
                this.getFromFlixelGamepadButton(RIGHT_STICK_CLICK);
            case PLUS:
                this.getFromFlixelGamepadButton(START);
            case MINUS:
                this.getFromFlixelGamepadButton(BACK);
            case HOME:
                this.getFromFlixelGamepadButton(GUIDE);
            case CAPTURE:
                this.getFromFlixelGamepadButton(EXTRA_0);
            default:
                NOT_PRESSED;
        }
    }

    override public function getConfirm():INPUT_STATE {
        return this.profile.getActionState(MENU_CONFIRM);
        return getButtonState(FACE_A);
    }

    override public function getCancel():INPUT_STATE {
        return this.profile.getActionState(MENU_CANCEL);
        return getButtonState(FACE_B);
    }

    override public function getMenuAction():INPUT_STATE {
        return this.profile.getActionState(MENU_ACTION);
        return getButtonState(FACE_X);
    }

    override public function getMenuLeft():INPUT_STATE {
        return this.profile.getActionState(MENU_LEFT);
        return InputHelper.or(getButtonState(LEFT_TRIGGER), getButtonState(LEFT_BUMPER));
    }

    override public function getMenuRight():INPUT_STATE {
        return this.profile.getActionState(MENU_RIGHT);
        return InputHelper.or(getButtonState(RIGHT_TRIGGER), getButtonState(RIGHT_BUMPER));
    }

    override public function getAttack():INPUT_STATE {
        return this.profile.getActionState(ATTACK);
        return getButtonState(FACE_A);
    }

    override public function getJump():INPUT_STATE {
        return this.profile.getActionState(JUMP);
        return InputHelper.or(getButtonState(FACE_X), getButtonState(FACE_Y));
    }

    override public function getSpecial():INPUT_STATE {
        return this.profile.getActionState(SPECIAL);
        return getButtonState(FACE_B);
    }

    override public function getStrong():INPUT_STATE {
        return this.profile.getActionState(STRONG);
        return getButtonState(NULL);
    }

    override public function getShield():INPUT_STATE {
        return this.profile.getActionState(SHIELD);
        return getButtonState(LEFT_TRIGGER);
    }

    override public function getWalk():INPUT_STATE {
        return this.profile.getActionState(WALK);
        return NOT_PRESSED; // unused on controller
    }

    override public function getTaunt():INPUT_STATE {
        return this.profile.getActionState(TAUNT);
        return InputHelper.or(getButtonState(DPAD_UP), getButtonState(DPAD_DOWN), getButtonState(DPAD_LEFT), getButtonState(DPAD_RIGHT));
    }

    override public function getQuit():INPUT_STATE {
        return this.profile.getActionState(NULL);
        return getButtonState(MINUS);
    }

    override public function getPause():INPUT_STATE {
        return this.profile.getActionState(NULL);
        return getButtonState(PLUS);
    }

    override public function getUp():Float {
        return -Math.min(this._flixelGamepad.getYAxis(LEFT_ANALOG_STICK) * 2, 0);
    }

    override public function getDown():Float {
        return Math.max(this._flixelGamepad.getYAxis(LEFT_ANALOG_STICK) * 2, 0);
    }

    override public function getLeft():Float {
        return -Math.min(this._flixelGamepad.getXAxis(LEFT_ANALOG_STICK) * 2, 0);
    }

    override public function getRight():Float {
        return Math.max(this._flixelGamepad.getXAxis(LEFT_ANALOG_STICK) * 2, 0);
    }

    override public function getStick():StickVector {
        // TODO : make this check the control scheme first!
        var x:Float = 0;
        var y:Float = 0;

        x += this.getRight();
        x -= this.getLeft();
        y += this.getDown();
        y -= this.getUp();

        return new StickVector(x, y);
    }

    override public function getCursorStick():StickVector {
        var stick = this.getStick();

        stick.x -= InputHelper.asInt(getButtonState(DPAD_LEFT));
        stick.x += InputHelper.asInt(getButtonState(DPAD_RIGHT));
        stick.y -= InputHelper.asInt(getButtonState(DPAD_UP));
        stick.y += InputHelper.asInt(getButtonState(DPAD_DOWN));

        if (stick.length > 1)
            stick.normalize();

        return stick;
    }

    override public function getDirection():StickVector {
        return new StickVector(0, 0);
    }

    override public function getRawDirection():StickVector {
        return new StickVector(0, 0);
    }
}
