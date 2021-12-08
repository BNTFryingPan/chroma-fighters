package inputManager;

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

enum INPUT_STATE {
    JUST_PRESSED;
    JUST_RELEASED;
    PRESSED;
    NOT_PRESSED;
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

enum ProfileInputType {
    AXIS;
    BUTTON;
}

enum CursorRotation {
    LEFT;
    RIGHT;
    UP_LEFT;
    UP_RIGHT;
    DOWN_LEFT;
    DOWN_RIGHT;
}