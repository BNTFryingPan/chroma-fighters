package inputManager;

import inputManager.GenericButton;

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
