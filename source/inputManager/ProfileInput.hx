package inputManager;

import flixel.input.keyboard.FlxKey;
import flixel.util.typeLimit.OneOfFour;
import flixel.util.typeLimit.OneOfThree;
import haxe.extern.EitherType;
import inputManager.GenericInput;
import inputManager.InputHelper;
import inputManager.InputState;
import inputManager.controllers.GenericController;

// typedef ProfileInputSource = EitherType<FlxKey, EitherType<GenericButton, GenericAxis>>;

typedef ProfileInputSource = OneOfThree<FlxKey, GenericButton, GenericAxis>;
typedef ProfileActionSource = OneOfFour<FlxKey, GenericButton, GenericAxis, ProfileInput>;

typedef ProfileInputOptions = {
   public var type:ProfileInputType; // the type of output this input is (axis or button)
   public var source:ProfileInputSource; // the actual button or axis of the input
   // if source is axis
   public var ?deadzone:Float; // if axis value is less than this value, it becomes 0
   // button options
   public var ?minThreshold:Float; // if the source type is an axis, the lowest axis value to trigger this button
   public var ?maxThreshold:Float; // ^ but the max value. could be used for different actions at different values
   // axis options
   public var ?digitalThreshold:Float; // the minimum value of the axis to count as a digital input (not sure when itll be used though)
   public var ?value:Float; // the axis value if the source type is a button
}

enum ProfileInputType {
   AXIS;
   BUTTON;
}

class ProfileInput {
   public static function getFromProfileAction(action:ProfileActionSource):ProfileInput {
      // $type(action);
      // Main.log('creating input with ${$type(action))}');
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

   public var source:ProfileInputSource;

   private var rawOptions:ProfileInputOptions;

   public final type:ProfileInputType;
   public var deadzone:Null<Float> = 0.05;
   public var minThreshold:Null<Float> = 0.05;
   public var maxThreshold:Null<Float> = 1;
   public var digitalThreshold:Null<Float> = 0.25;
   public var value:Null<Float> = 1;

   public function new(options:ProfileInputOptions) {
      trace('new profile input');
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

   private function getAxisValue(?gamepad:GenericInput):Float {
      if (this.isDigitalSource())
         return 0.0;
      return 0.0;
   }

   public function getDigitalState(?gamepad:GenericInput):Bool {
      if (Std.isOfType(this.source, Int)) {
         return InputHelper.isPressed(InputHelper.getFromFlxKey(cast this.source));
      } else if (gamepad == null) {
         return false;
      } else if (Std.isOfType(this.source, GenericButton)) {
         return InputHelper.isPressed((cast gamepad).getButtonState(cast this.source));
      }
      return (this.getAxisValue() > this.digitalThreshold ? true : false);
   }

   public function getInputState(?gamepad:GenericInput):InputState {
      if (this.type == AXIS) {
         return NOT_PRESSED; // you cant really "press" an output axis. axis input can be "pressed" though
      }
      if (Std.isOfType(this.source, Int) && gamepad == null) { // if gamepad is not null, then dont check keyboard input for this action
         return InputHelper.getFromFlxKey(cast this.source);
      }
      try {
         trace(!Std.isOfType(this.source, Int)); /*Std.isOfType(this.source, GenericButton)*/
         if ((!Std.isOfType(this.source, Int)) && gamepad != null) {
            var button:GenericButton = cast this.source;
            var ret = (cast gamepad).getButtonState(button);
            trace(ret);
            return ret;
         }
      }
      catch (e) {
         trace('failed!');
      }
      // trace(this.source); // if (gamepad != null)
      // trace(gamepad == null ? 'no gamepad + fallback' : Std.string(gamepad));
      return NOT_PRESSED; // fall back
   }

   /**
    * returns the actual value of the input as a float between -1.0 or 0.0 and 1.0
   **/
   public function getInputValue(?gamepad:GenericInput):Float {
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
