package inputManager.controllers;

import PlayerSlot.PlayerSlotIdentifier;
import flixel.input.gamepad.FlxGamepad;
import flixel.input.gamepad.FlxGamepadButton;
import flixel.input.gamepad.FlxGamepadInputID;
import inputManager.GenericInput;
import inputManager.InputHelper;

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
   public function getFromFlixelGamepadButton(button:FlxGamepadInputID):InputState {
      if (!this._flixelGamepad.connected)
         return NOT_PRESSED;
      return InputHelper.getFromFlxInput(this._flixelGamepad.getButton(this._flixelGamepad.mapping.getRawID(button)));
   }

   public function getAxisValue(axis:GenericAxis):Float {
      return switch (axis) {
         case LEFT_STICK_X:
            this._flixelGamepad.analog.value.LEFT_STICK_X;
         default: 0.0;
      }
   }

   public function getButtonState(button:GenericButton):InputState {
      return switch (button) {
         case NULL:
            NOT_PRESSED;
         case TRUE:
            if (!this._flixelGamepad.connected) NOT_PRESSED; else PRESSED;
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

   override public function getConfirm():InputState {
      return this.profile.getActionState(MENU_CONFIRM, this);
   }

   override public function getCancel():InputState {
      return this.profile.getActionState(MENU_CANCEL, this);
   }

   override public function getMenuAction():InputState {
      return this.profile.getActionState(MENU_ACTION, this);
   }

   override public function getMenuLeft():InputState {
      return this.profile.getActionState(MENU_LEFT, this);
   }

   override public function getMenuRight():InputState {
      return this.profile.getActionState(MENU_RIGHT, this);
   }

   override public function getMenuButton():InputState {
      return this.profile.getActionState(MENU_BUTTON, this);
   }

   override public function getAttack():InputState {
      return this.profile.getActionState(ATTACK, this);
   }

   override public function getJump():InputState {
      return this.profile.getActionState(JUMP, this);
   }

   override public function getShortJump():InputState {
      return this.profile.getActionState(SHORT_JUMP, this);
   }

   override public function getSpecial():InputState {
      return this.profile.getActionState(SPECIAL, this);
   }

   override public function getStrong():InputState {
      return this.profile.getActionState(STRONG, this);
   }

   override public function getShield():InputState {
      return this.profile.getActionState(SHIELD, this);
   }

   override public function getDodge():InputState {
      return this.profile.getActionState(DODGE, this);
   }

   override public function getWalk():InputState {
      return this.profile.getActionState(WALK, this);
      // return NOT_PRESSED; // unused on controller
   }

   override public function getTaunt():InputState {
      return this.profile.getActionState(TAUNT, this);
   }

   override public function getQuit():InputState {
      return this.getButtonState(MINUS);
      // return this.profile.getActionState(NULL, this);
   }

   override public function getPause():InputState {
      return this.getButtonState(PLUS);
      // return this.profile.getActionState(NULL, this);
   }

   override public function getUp():Float {
      return -Math.min(this._flixelGamepad.getYAxis(LEFT_ANALOG_STICK), 0);
   }

   override public function getDown():Float {
      return Math.max(this._flixelGamepad.getYAxis(LEFT_ANALOG_STICK), 0);
   }

   override public function getLeft():Float {
      return -Math.min(this._flixelGamepad.getXAxis(LEFT_ANALOG_STICK), 0);
   }

   override public function getRight():Float {
      return Math.max(this._flixelGamepad.getXAxis(LEFT_ANALOG_STICK), 0);
   }

   override public function getStick():StickVector {
      return super.getStick().normalize();
   }

   override public function getCursorStick():StickVector {
      var stick = this.getStick();

      stick.x -= InputHelper.asInt(getButtonState(DPAD_LEFT));
      stick.x += InputHelper.asInt(getButtonState(DPAD_RIGHT));
      stick.y -= InputHelper.asInt(getButtonState(DPAD_UP));
      stick.y += InputHelper.asInt(getButtonState(DPAD_DOWN));

      if (Math.sqrt((stick.x * stick.x) + (stick.y * stick.y)) > 1) {
         var len = Math.sqrt((stick.x * stick.x) + (stick.y * stick.y));
         stick.x /= len;
         stick.y /= len;
      }

      return stick;
   }
   /*override public function getDirection():StickVector {
         return new// StickVector(0, 0);
         // return {x: 0, y: 0};
      }

      override public function getRawDirection():StickVector {
         return new// StickVector(0, 0);
         // return {x: 0, y: 0};
   }*/
}
