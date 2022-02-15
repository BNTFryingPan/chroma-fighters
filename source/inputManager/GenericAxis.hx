package inputManager;

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
