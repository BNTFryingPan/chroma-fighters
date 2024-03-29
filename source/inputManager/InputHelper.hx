package inputManager;

import flixel.FlxG;
import flixel.input.FlxInput;
import flixel.input.gamepad.FlxGamepad;
import flixel.input.keyboard.FlxKey;
import inputManager.InputState;

class InputHelper {
   static public function isPressingConnectCombo(gamepad:FlxGamepad):Bool {
      return (gamepad.pressed.LEFT_SHOULDER && gamepad.pressed.RIGHT_SHOULDER)
         || (gamepad.pressed.RIGHT_TRIGGER_BUTTON && gamepad.pressed.LEFT_TRIGGER_BUTTON);
      /*if (gamepad.anyPressed([LEFT_SHOULDER])
            && gamepad.anyPressed([RIGHT_SHOULDER])
            && gamepad.anyJustPressed([LEFT_SHOULDER, RIGHT_SHOULDER])) {
            return true;
         } else if (gamepad.pressed.LEFT_TRIGGER && gamepad.pressed.RIGHT_TRIGGER && gamepad.anyJustPressed([LEFT_TRIGGER, RIGHT_TRIGGER])) {
            return true;
         }
         return false; */
   }

   static public function isPressed(state:InputState):Bool {
      if (state == JUST_PRESSED) {
         return true;
      }
      return state == PRESSED;
   }

   static public function isNotPressed(state:InputState):Bool {
      if (state == JUST_RELEASED) {
         return true;
      }
      return state == NOT_PRESSED;
   }

   static public function justChanged(state:InputState):Bool {
      if (state == JUST_PRESSED) {
         return true;
      }
      return state == JUST_RELEASED;
   }

   static public function notChanged(state:InputState):Bool {
      if (state == PRESSED) {
         return true;
      }
      return state == NOT_PRESSED;
   }

   static public function getFromFlixel(justPressed:Bool, justReleased:Bool, pressed:Bool):InputState {
      if (justPressed)
         return JUST_PRESSED;
      if (justReleased)
         return JUST_RELEASED;
      if (pressed)
         return PRESSED;
      return NOT_PRESSED;
   }

   static public function getFromFlxInput(input:FlxInput<Int>):InputState {
      if (input.justPressed)
         return JUST_PRESSED;
      if (input.justReleased)
         return JUST_RELEASED;
      if (input.pressed)
         return PRESSED;
      return NOT_PRESSED;
   }

   @:access(flixel.input.FlxKeyManager)
   static public function getFromFlxKey(key:FlxKey):InputState {
      return InputHelper.getFromFlxInput(FlxG.keys.getKey(key));
   }

   static public function or(...inputs:InputState):InputState {
      if (inputs.length == 0) {
         return NOT_PRESSED;
      }

      var asArray = inputs.toArray();

      if (asArray.contains(PRESSED))
         return PRESSED;

      if (asArray.contains(JUST_PRESSED)) {
         if (asArray.contains(JUST_RELEASED))
            return PRESSED;
         return JUST_PRESSED;
      }

      if (asArray.contains(JUST_RELEASED))
         return JUST_RELEASED;

      return NOT_PRESSED;
   }

   static public function asInt(state:InputState):Int {
      return InputHelper.isPressed(state) ? 1 : 0;
   }

   static public function realJumpState(input:GenericInput):InputState {
      var jump = input.getJump();
      var shortJump = input.getShortJump();

      if (InputHelper.isPressed(jump) || jump == JUST_RELEASED)
         return jump;

      if (shortJump == JUST_PRESSED)
         return JUST_PRESSED;

      return NOT_PRESSED;
   }
   /*
      static public function badUnitTest():Bool {
         Main.log('NOT_PRESSED   + NOT_PRESSED  : ${or(NOT_PRESSED, NOT_PRESSED)}');
         Main.log('NOT_PRESSED   + JUST_PRESSED : ${or(NOT_PRESSED, JUST_PRESSED)}');
         Main.log('NOT_PRESSED   + PRESSED      : ${or(NOT_PRESSED, PRESSED)}');
         Main.log('NOT_PRESSED   + JUST_RELEASED: ${or(NOT_PRESSED, JUST_RELEASED)}');
         Main.log('JUST_PRESSED  + NOT_PRESSED  : ${or(JUST_PRESSED, NOT_PRESSED)}');
         Main.log('JUST_PRESSED  + JUST_PRESSED : ${or(JUST_PRESSED, JUST_PRESSED)}');
         Main.log('JUST_PRESSED  + PRESSED      : ${or(JUST_PRESSED, PRESSED)}');
         Main.log('JUST_PRESSED  + JUST_RELEASED: ${or(JUST_PRESSED, JUST_RELEASED)}');
         Main.log('PRESSED       + NOT_PRESSED  : ${or(PRESSED, NOT_PRESSED)}');
         Main.log('PRESSED       + JUST_PRESSED :  ${or(PRESSED, JUST_PRESSED)}');
         Main.log('PRESSED       + PRESSED      : ${or(PRESSED, PRESSED)}');
             Main.log('PRESSED       + JUST_RELEASED: ${or(PRESSED, JUST_RELEASED)}');
             Main.log('JUST_RELEASED + NOT_PRESSED  : ${or(JUST_RELEASED, NOT_PRESSED)}');
             Main.log('JUST_RELEASED + JUST_PRESSED : ${or(JUST_RELEASED, JUST_PRESSED)}');
             Main.log('JUST_RELEASED + PRESSED      : ${or(JUST_RELEASED, PRESSED)}');
             Main.log('JUST_RELEASED + JUST_RELEASED: ${or(JUST_RELEASED, JUST_RELEASED)}');
             return true;
         }

         static public var a = badUnitTest();
    */
}
