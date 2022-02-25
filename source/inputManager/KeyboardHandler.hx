package inputManager;

import PlayerSlot.PlayerSlotIdentifier;
import flixel.FlxG;
import flixel.input.keyboard.FlxKey;
import inputManager.InputState;

/**
   input handler for keyboard
**/
class KeyboardHandler extends GenericInput {
   override public function get_inputType() {
      return "Keyboard";
   }

   override public function get_inputEnabled() {
      return true;
   }

   override public function new(slot:PlayerSlotIdentifier, ?profile:String) {
      super(slot, profile);
   }

   public static function getKeyStateAsInputState(key:FlxKey) {
      var k = [key];

      if (FlxG.keys.anyJustPressed(k)) {
         return JUST_PRESSED;
      }

      if (FlxG.keys.anyJustReleased(k)) {
         return JUST_RELEASED;
      }

      if (FlxG.keys.anyPressed(k)) {
         return PRESSED;
      }

      return NOT_PRESSED;
   }

   override public function getConfirm():InputState {
      return getKeyStateAsInputState(Z);
   }

   override public function getCancel():InputState {
      return getKeyStateAsInputState(X);
   }

   override public function getMenuAction():InputState {
      return getKeyStateAsInputState(C);
   }

   override public function getMenuLeft():InputState {
      return getKeyStateAsInputState(A);
   }

   override public function getMenuRight():InputState {
      return getKeyStateAsInputState(S);
   }

   override public function getAttack():InputState {
      return getKeyStateAsInputState(X);
   }

   override public function getJump():InputState {
      return getKeyStateAsInputState(Z);
   }

   override public function getSpecial():InputState {
      return getKeyStateAsInputState(C);
   }

   override public function getStrong():InputState {
      return getKeyStateAsInputState(D);
   }

   override public function getDodge():InputState {
      return getKeyStateAsInputState(S);
   }

   override public function getWalk():InputState {
      return getKeyStateAsInputState(A);
   }

   override public function getTaunt():InputState {
      return getKeyStateAsInputState(F);
   }

   override public function getQuit():InputState {
      return getKeyStateAsInputState(BACKSPACE);
   }

   override public function getPause():InputState {
      return getKeyStateAsInputState(ENTER);
   }

   override public function getUp():Float {
      return FlxG.keys.pressed.UP ? 1 : 0;
   }

   override public function getDown():Float {
      return FlxG.keys.pressed.DOWN ? 1 : 0;
   }

   override public function getLeft():Float {
      return FlxG.keys.pressed.LEFT ? 1 : 0;
   }

   override public function getRight():Float {
      return FlxG.keys.pressed.RIGHT ? 1 : 0;
   }

   override public function getStick():StickVector {
      // TODO : make this check the control scheme first!
      var x:Float = 0;
      var y:Float = 0;

      y -= this.getUp();
      y += this.getDown();
      x -= this.getLeft();
      x += this.getRight();

      return new StickVector(x * (InputHelper.isPressed(this.getWalk()) ? 0.4 : 1), y);
      // return {x: x, y: y};
   }

   override public function getCursorStick():StickVector {
      return this.getStick().normalize(); // todo: normalize
   }

   override public function getDirection():StickVector {
      return new StickVector(0, 0);
      // return {x: 0, y: 0};
   }

   override public function getRawDirection():StickVector {
      return new StickVector(0, 0);
      // return {x: 0, y: 0};
   }
}
