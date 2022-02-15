package inputManager;

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
