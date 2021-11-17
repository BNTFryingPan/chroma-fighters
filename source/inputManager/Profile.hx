package inputManager;

import flixel.FlxG;
import flixel.input.gamepad.FlxGamepad;
import flixel.input.keyboard.FlxKey;
import flixel.util.typeLimit.OneOfTwo;
import inputManager.GenericInput.INPUT_STATE;
import inputManager.GenericInput.InputHelper;
import inputManager.InputManager.Action;
import inputManager.controllers.GenericController;

typedef ProfileAction = OneOfTwo<FlxKey, GenericButton>;

class Profile {
    public static function getProfile(name:String) {
        // TODO : load and create the players profile
        return new Profile();
    }

    public var name:String;
    public var fileName:String;

    public var bindings:Map<Action, Array<ProfileAction>> = [
        MENU_CONFIRM => [FlxKey.Z, FACE_A], MENU_CANCEL => [X, FACE_B], MENU_ACTION => [C, FACE_X, FACE_Y], MENU_LEFT => [A, LEFT_TRIGGER, LEFT_BUMPER],
        MENU_RIGHT => [S, RIGHT_TRIGGER, RIGHT_BUMPER], JUMP => [X, FACE_X, FACE_Y], SHORT_JUMP => [V, RIGHT_BUMPER], ATTACK => [FlxKey.Z, FACE_A],
        SPECIAL => [C, FACE_B], STRONG => [D], TAUNT => [F, DPAD_UP, DPAD_DOWN, DPAD_LEFT, DPAD_RIGHT],
        SHIELD => [S, LEFT_BUMPER, LEFT_TRIGGER, RIGHT_TRIGGER], WALK => [A]];

    public function new() {}

    private var input:Null<GenericInput>;

    private function getOwningPlayerFromInputManager():Null<GenericInput> {
        if (this.input != null)
            return this.input;

        var owner = InputManager.getPlayerByProfileName(this.name);
        if (owner == null)
            return null;

        this.input = owner;
        return this.input;
    }

    @:access(flixel.input.FlxKeyManager)
    public function checkActionArray(list:Array<ProfileAction>):INPUT_STATE {
        if (this.getOwningPlayerFromInputManager() == null)
            return NOT_PRESSED;

        var pressed:Array<INPUT_STATE>;

        if (Std.isOfType(this.input, KeyboardHandler))
            pressed = list.map(action -> {
                if (Std.isOfType(action, GenericButton))
                    return NOT_PRESSED;

                return InputHelper.getFromFlxInput(FlxG.keys.getKey(cast action));
            });
        else if (Std.isOfType(this.input, GenericController))
            pressed = list.map(action -> {
                if (Std.isOfType(action, Int))
                    return NOT_PRESSED;

                return (cast this.input).getButtonState(cast action);
            });
        else
            return NOT_PRESSED;
        return InputHelper.or(...pressed);
    }

    public function getAction(action:Action, gamepad:FlxGamepad):INPUT_STATE {
        return NOT_PRESSED; // switch (action) {
        // case MENU_CONFIRM;
        // }
    }
}
