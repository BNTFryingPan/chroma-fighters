package inputManager;

import flixel.input.keyboard.FlxKey;
import flixel.util.typeLimit.OneOfFour;
import flixel.util.typeLimit.OneOfThree;
import inputManager.InputEnums;
import inputManager.ProfileInput;

typedef Position = {
   var x:Int;
   var y:Int;
}

typedef StickValue = {
   public var x:Float;
   public var y:Float;
}

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
