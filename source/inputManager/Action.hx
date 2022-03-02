package inputManager;

enum Action {
   NULL; // never true
   MENU_CONFIRM;
   MENU_CANCEL;
   MENU_ACTION;
   MENU_LEFT;
   MENU_RIGHT;
   MENU_BUTTON;
   JUMP;
   SHORT_JUMP;
   ATTACK;
   SPECIAL;
   STRONG;
   TAUNT;
   SHIELD; // might only do parries, not sure yet
   DODGE;
   WALK;
   DIRECTION_X;
   DIRECTION_Y;
   MOVE_X;
   MOVE_Y;

   MODIFIER_X;
   MODIFIER_Y;
}
